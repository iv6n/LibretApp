import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:libretapp/core/backup/backup_identity.dart';
import 'package:libretapp/core/backup/backup_operation_lock.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';
import 'package:libretapp/core/backup/supabase_cloud_backup_repository.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const owner = '22000000-0000-0000-0000-000000000001';
  const phone = '525555123456';
  const account = LocalWorkspace(id:'local-a', kind:WorkspaceKind.account, userId:owner);
  late LocalWorkspace active;
  late SupabaseClient client;
  late List<http.Request> requests;
  late Map<String,dynamic>? row;
  final archive = Uint8List.fromList([1,2,3,4]);
  var loseUploadResponse = false;
  var loseVerifyResponse = false;
  var wifi = true;
  late SupabaseCloudBackupRepository repository;

  setUp(() async {
    requests = []; row = null; active = account;
    loseUploadResponse = false; loseVerifyResponse = false; wifi = true;
    client = SupabaseClient('https://connected.test','anon-public-key',
      authOptions: const AuthClientOptions(autoRefreshToken:false),
      httpClient: MockClient((request) async {
        requests.add(request);
        http.Response response(String body, int status, {Map<String,String>? headers}) =>
            http.Response(body,status,headers:headers ?? {},request:request);
        if (request.url.path.endsWith('/verify')) return response(jsonEncode({
          'access_token':'test-token','refresh_token':'refresh','token_type':'bearer','expires_in':3600,
          'user':{'id':owner,'aud':'authenticated','phone':phone,
            'phone_confirmed_at':'2026-10-22T00:00:00Z', 'created_at':'2026-10-22T00:00:00Z',
            'app_metadata':{},'user_metadata':{}},
        }),200);
        if (request.url.path.contains('/storage/v1/object/')) {
          if (request.method == 'POST') {
            if (loseUploadResponse) { loseUploadResponse = false; return response('{"message":"response lost"}',500); }
            return response('{"Key":"accepted"}',200);
          }
          if (request.method == 'GET') return http.Response.bytes(archive,200,request:request);
          return response('[]',200);
        }
        if (request.method == 'POST') {
          row = Map<String,dynamic>.from(jsonDecode(request.body) as Map)
            ..['created_at'] = '2026-10-22T00:00:00Z';
          return response('[]',201,headers:{'content-type':'application/json'});
        }
        if (request.method == 'PATCH') {
          row!['verified'] = true;
          if (loseVerifyResponse) { loseVerifyResponse = false; return response('{"message":"response lost"}',500); }
          return response(jsonEncode(row),200,headers:{'content-type':'application/json'});
        }
        if (request.url.queryParameters['verified'] == 'eq.false') return response('[]',200);
        return response(jsonEncode(row == null ? [] : [row]),200,headers:{'content-type':'application/json'});
      }));
    await client.auth.verifyOTP(phone:'+$phone',token:'123456',type:OtpType.sms);
    requests.clear();
    repository = SupabaseCloudBackupRepository(client, identity: BackupIdentity(
      workspace: account, activeWorkspace: () async => active), wifiAvailable: () async => wifi);
  });
  tearDown(() => client.dispose());

  Future<void> upload() async {
    await repository.uploadSnapshot(bytes:archive, sha256:sha256.convert(archive).toString(),
      schemaVersion:11,appVersion:'test');
  }
  test('guest, demo and a different active owner cannot even list remote copies', () async {
    for (final space in [
      const LocalWorkspace(id:'guest',kind:WorkspaceKind.guest),
      const LocalWorkspace(id:'demo',kind:WorkspaceKind.demo),
      const LocalWorkspace(id:'local-b',kind:WorkspaceKind.account,userId:'other'),
    ]) {
      active = space;
      await expectLater(repository.listSnapshots(),throwsA(isA<CloudBackupUnavailable>()));
      await expectLater(upload(),throwsA(isA<CloudBackupUnavailable>()));
    }
    expect(requests,isEmpty);
  });
  test('lost upload response reconciles the same object without another upload', () async {
    loseUploadResponse = true;
    await upload();
    expect(row!['verified'],isTrue);
    expect(requests.where((r)=>r.method=='POST' && r.url.path.contains('/storage/')).length,1);
    expect(requests.where((r)=>r.method=='DELETE'),isEmpty);
  });
  test('lost verification response retries metadata without deleting the accepted copy', () async {
    loseVerifyResponse = true;
    await upload();
    expect(requests.where((r)=>r.method=='PATCH').length,2);
    expect(requests.where((r)=>r.method=='DELETE'),isEmpty);
    expect(row!['verified'],isTrue);
  });
  test('cellular-only connection blocks upload before reservation or Storage', () async {
    wifi = false;
    await expectLater(upload(),throwsA(isA<CloudBackupUnavailable>()));
    expect(requests,isEmpty);
  });
  test('invalid digest is rejected before remote mutation', () async {
    await expectLater(repository.uploadSnapshot(bytes:archive,sha256:'0'*64,
      schemaVersion:11,appVersion:'test'),throwsFormatException);
    expect(requests,isEmpty);
  });

  test('operation lock serializes independent callers and releases after failure', () async {
    final root = await Directory.systemTemp.createTemp('libret-operation-lock-');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'),(_) async=>root.path);
    final entered = Completer<void>(); final release = Completer<void>();
    final events = <String>[];
    final first = BackupOperationLock().run(() async { events.add('first'); entered.complete(); await release.future; });
    await entered.future;
    final second = BackupOperationLock().run(() async { events.add('second'); throw StateError('disk failure'); });
    final secondResult = expectLater(second,throwsStateError);
    expect(events,['first']);
    release.complete(); await first; await secondResult;
    await BackupOperationLock().run(() async { events.add('third'); });
    expect(events,['first','second','third']);
    messenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'),null);
    await root.delete(recursive:true);
  });
}
