import 'package:graphql/client.dart';

main() async {
  final HttpLink httpLink = HttpLink(
    'https://hasura-3fad0791.nhost.app/v1/graphql',
  );
  final _authLink = AuthLink(getToken: () {
    return '06b94e1e71388f27e6ab5c5af4c87249';
  }, headerKey: 'x-hasura-admin-secret');
  final client = GraphQLClient(link: _authLink.concat(httpLink), cache: GraphQLCache());

  String readRepositories = """
  subscription GetDonation {
    temp_money_donations {
      created_at
      donator
      id
      updated_at
      value
    }
  
  }
  
  subscription GetUsage {
    temp_money_used_for {
      created_at
      id
      storage_image_name
      updated_at
      usage
      value
    }
  }
""";
  final results = await client.query(QueryOptions(document: gql(readRepositories), variables: {}));
  if (results.hasException) {
    print(results.exception.toString());
  }
  print(results.data);
}
