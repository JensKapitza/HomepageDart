import 'package:postgrest/postgrest.dart';

void main() async {
  print("test ---");

  var url = 'http://localhost:3000';
  var client = PostgrestClient(url);

  var response = await client.from('test').insert([
    {'a': 231, 'b': 'ONLINE'}
  ]).execute();

  response = await client.from('test').select().execute();

  print(response.toJson());
}
