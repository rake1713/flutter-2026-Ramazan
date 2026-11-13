# Practice 11 notes

## Level 1 - Postman / curl

GET /users -> 200, Content-Type: application/json; charset=utf-8, a list of 10 users.
GET /users/1 -> 200, one object.

User:

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| id | number | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| address | object | Address | no |
| phone | string | String | no |
| website | string | String? | yes (I treat it as optional) |
| company | object | record (name, catchPhrase) | no |

address:

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object (nested twice: address.geo) | Geo | no |

geo: lat and lng come as strings like "-37.3159", so in Dart they are double with double.parse.

company:

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | not used | - |

GET /users/999 -> 404, body is just {}
POST /users with name, username, email -> 201, the server sends back my fields and adds "id": 11
GET /users?id=3 -> 200, a list with one user, not an object

## Level 2

user 1 from the pasted JSON printed: User(1, Leanne Graham, Gwenborough)
`json['lat'] as double` -> type 'String' is not a subtype of type 'double' in type cast
id as "1" -> type 'String' is not a subtype of type 'int' in type cast

## Level 3

getAll() -> 10 names
getById(999) -> NotFoundException -> printed "not found"
create(...) -> id 11

grep -rn "package:http" lib/ shows api_client.dart, user_repository.dart and main.dart.
main.dart is there because it is the composition root and has to say http.Client().

Without the 404 line in _check, getById(999) gave:
BadResponseException users/999: type 'Null' is not a subtype of type 'int' in type cast
Still my exception, but it blames the JSON instead of the real cause (404). So status is checked first.

## Level 4

Removed the BadResponseException() arm:
The type 'ApiException?' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'BadResponseException()'

Host typo jsonplaceholder.typicode.co -> Offline view with Retry, fixed host -> Retry loads the list.

## Level 5 - two kinds of no network

No route (host that does not exist): NoConnectionException after 48 ms
Packets that never come back (address that does not answer): NoConnectionException after 10002 ms, this is the 10 second timeout
