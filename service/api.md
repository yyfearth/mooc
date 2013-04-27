RESTful API (Draft)
===========

-- Proposed by Wilson (Yufan) Yang <yyfearth@gmail.com>

Use JSON as the format for the body of both request and response, except for login and view.

For all response, there should be a header: `Content-Type: application/json; charset=utf-8`

The RESTful API URL patterns is designed by following the recommendation from the Book: OReilly - Restful Web Services Cookbook (2010).

Some principals I followed:

1. Stateless - no session is stored
2. Represents as Resources/Services (Nouns) instead of Actions (Verbs)
3. Use single noun for resource deal with a single entity (e.g. create and search/list), use plural for a set of entities (e.g. get by ID, update and delete)
4. Using lowercase_separated_by_underscores followed the naming convention of Ruby, Python and MongoDB  
5. Using standard [HTTP Status Code](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) to indicate the results

Currently, the API is mainly designed for the server-to-server interaction,
for clients, it should be some additional authentication and authorization needed. 
Basic Auth and OAuth should be introduced for Access control, but I think we do not have enough time for that.

**Some requirements:**

1. When creating entity, the API must return 201 with created entity’s JSON, and the URL with its ID in the `Location` Header
2. All get by ID method support GET and HEAD method, when use HEAD it should return the same status code as GET but no content returned
3. For most entities, use POST to create, PUT to update, GET to query and DELETE to remove
4. For some APIs does not return entity(ies), it should return a Success JSON to indicate it success, and all exception should return a proper Status Code (400 for Bad Request, 404 for 5. Not Found, 500 for Internal Error, etc.) with a Error JSON.
5. Some entity(ies) has a View API, it should redirect to your corresponding page in your web server


---

Login / Logout
--------------

### User Login

#### Usage

* Use for login into system for both service provider and consumer(server or client).  
POST email and password to login, or use GET without password to just display the login page.
* A callback URL should given if it designed to go back to the consumer’s web page.
* The service provider should create a session id and write to the cookie.
* It is NOT a RESTful API, instead it an API for web interface, designed for the teams do not want to implement the login page in their own web server.
* It should be implemented by the teams, who selected the user parts, in there web server.

#### Request

Method | URL | Request Body (Encoded Form)
-------|-----|-------------
POST | http://host:port/login?callback=`:url` | email=`:email`&password=`:password`
GET | http://host:port/login?email=`:email`&callback=`:url` | -

##### Parameters

Parameter | Value | Method
----------|-------|-------
callback | The URL direct to after login successfully | GET (in URL) / POST (in Body)
email | The email of the user want to login | GET (in URL) / POST (in Body)
password | The original not hashed password | Must use POST (in Body)

#### Response

* It always show the login page, email should be already filled in if it is given.
* If both the email and password are given via POST, the page should submit automatically.
* After login succeed, it will redirect to the URL given in the callback parameter, 
if it is not given, just go to the default page after login.
* If login failed, just go back to the login page and require the user login manually, 
but please preserve the callback URL, since it should work after a success login.


### User Logout

#### Usage

* Use for logout the system for both service provider and consumer(server or client).
* Just call the logout URL, and it should be clear the session if user logged in. 
* A callback URL should given if it designed to go back to the consumer’s web page.
* The service provider should clear the session id and the cookie.
* It is NOT a RESTful API, instead it an API for web interface, designed for the teams do not want to implement the login page in their own web server.
* It should be implemented by the teams, who selected the user parts, in there web server.

#### Request

Method | URL
-------|----
GET | http://host:port/logout?callback=`:url`

##### Parameters

Parameter | Value
----------|------
callback  | The URL direct to after logged out successfully

#### Response

* It should be the same behavior as user logout using the provider's web GUI.
* After logged out, it will redirect to the URL given in the callback parameter,
if it is not given, just go to the default page after logged out.
* If user is not logged in or any other errors, it should display the error
information in a page as same as a user using the web GUI.

## User

### User Validation

#### Usage

* This is a programmatic way to check the user’s authentication, can be used for
* User Login in server-side only, but not equal to login.
* Currently, [Basic Auth](http://en.wikipedia.org/wiki/Basic_access_authentication) (email + password) should be supported.
* For Basic Auth: Use the user’s email as its “username” and user SHA-1 hashed password as its “password”.

#### Request

Method | URL | Request Header
-------|-----|---------------
GET | http://host:port/user/validation | (Authorization Header Needed)

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Success
400 (Bad Request) | Error JSON | Email is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

### Get User by Email

#### Usage

* It used for any situation when servers or clients need the user’s information by given email.
* DO NOT use it for User Login, since it is not require a password and not return with password.

#### Request

Method | URL
-------|----
GET | http://host:port/user/`:email`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | User JSON w/o password | Success
400 (Bad Request) | Error JSON | Email is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

### View User by Email

#### Usage

* It will redirect to the specified user profile’s web view of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL
-------|----
GET | http://host:port/user/`:email`/view

#### Response

* It should redirect to the URL of the web view for the specified user profile using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Search Users

### Create User

#### Usage

* Create a new user for user registration.
* The password should be always hashed by SHA-1, lower-cased hex string.

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/user**s** | User JSON with password

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | User JSON | Success
409 (Conflict) | Error JSON | Email is duplicated
500 (Internal Server Error) | Error JSON | Other Errors

### Save/Update User

#### Usage

* Can be used for both creating and updating user, since the email address is unique.

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/user/`:email` | User JSON *

* Password is required for creating new user, but it will be ignored for updating.

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | User JSON w/o password | Create new user if not exists
200 (OK) | User JSON w/o password | Update existing user
400 (Bad Request) | Error JSON | Email or JSON is invalid
500 (Internal Server Error) | Error JSON | Other Errors

### Update User Password

#### Usage

* Since update user do not contain password, use this to change user’s password.
* The password should be always hashed by SHA-1, lower-cased hex string.

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/user/`:email`/password | The hashed password

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | User JSON w/o password | Update successful
400 (Bad Request) | Error JSON | Email or password is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

### Delete User

#### Request

Method | URL
-------|----
DELETE | http://host:port/user/`:email`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | Email is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

## Category

### Get Category by ID

#### Request

Method | URL
-------|----
GET | http://host:port/category/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Category JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Category not found
500 (Internal Server Error) | Error JSON | Other Errors

### View Category by ID

#### Usage

* It will redirect to the specified category’s web view (may show the courses) of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL
-------|----
GET | http://host:port/category/`:id`/view

#### Response

* It should redirect to the URL of the web view for the specified category using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### List All Categories

#### Request

Method | URL
-------|----
GET | http://host:port/categor**ies**

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Category Array JSON | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Add Category

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/categor**ies** | Category JSON w/o ID

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | Category JSON w/ ID | Success
409 (Conflict) | Error JSON | Name is duplicated
500 (Internal Server Error) | Error JSON | Other Errors

### Update Category

#### Request

Method | URL
-------|----
PUT | http://host:port/category/`:id` | Category JSON

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Category JSON | Update success
400 (Bad Request) | Error JSON | ID or JSON is invalid
404 (Not Found) | Error JSON | Category not found
500 (Internal Server Error) | Error JSON | Other Errors

### Delete Category

#### Request

Method | URL | Request Body
-------|-----|-------------
DELETE | http://host:port/category/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

## Course

### Get Course by ID

#### Request

Method | URL
-------|----
GET | http://host:port/course/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Course JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Course not found
500 (Internal Server Error) | Error JSON | Other Errors

### View Course by ID

#### Usage

* It will redirect to the course home page of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL
-------|----
GET | http://host:port/course/`:id`/view

#### Response

* It should redirect to the URL of the specified course home page using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Search Courses

#### Request

Method | URL
-------|----
GET | http://host:port/course**s**?param=value&...

##### Parameters

* All parameters are optional, usually are specified by default. If no parameter is given, return all.

Parameter | Value
----------|------
q | A part of title, description, category, etc. (like google search)
title | Exactly the title
category_id | Exactly the category
participant_email | One of the participants’ email
created_by | Exactly the creator’s email
created_from/created_to | The time span for created_at property
updated_from/updated_to | The time span for updated_at property, can be used for Sync
offset | For paging, the offset index of entity for this return, default 0
limit | For paging, the numbers of entity for this return, default is unlimited?
order_by | For ordering and paging, default is order by id

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Course Array JSON | Success
500 (Internal Server Error) | Error JSON | Other Errors

### View Course List

#### Usage

* It will redirect to the course list page of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/course**s**/view

#### Response

* It should redirect to the URL of the course list page using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Add Course

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/course**s** | Course JSON w/o ID

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | Course JSON w/ ID | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Update Course

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/course/`:id` | Course JSON

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Course JSON | Update success
400 (Bad Request) | Error JSON | ID or JSON is invalid
404 (Not Found) | Error JSON | Course not found
500 (Internal Server Error) | Error JSON | Other Errors

### Delete Course

#### Request

Method | URL | Request Body
-------|-----|-------------
DELETE | http://host:port/course/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

### List All Participants

#### Usage

* A shortcut for getting all participants’ user profile, to avoid fetching the participants one by one.
* It will return all user entities without additionally attribute like role.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/course/`:id`/participant**s**

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | User Array JSON w/o password | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Course not found
500 (Internal Server Error) | Error JSON | Other Errors

### View Participants List

#### Usage

* It will redirect to the specified participants web view of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/course/`:id`/participant**s**/view

#### Response

* It should redirect to the URL of the web view for the specified user profile
using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Drop / Enroll Course

* Just update the course entity with course id by adding or removing a user from the participants.

## Announcement

### Get Announcement by ID

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/announcement/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Announcement JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Announcement not found
500 (Internal Server Error) | Error JSON | Other Errors

### View Announcement by ID

#### Usage

* It will redirect to the specified announcement web view, of the service provider, show messages.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/announcement/`:id`/view

#### Response

* It should redirect to the URL of the web view for the specified announcement
using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### View Announcement List

#### Usage

* It will redirect to the announcement list web view of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/announcement**s**/view

#### Response

* It should redirect to the URL of the web view for the announcement list using
301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Search Announcements

#### Usage

* Search for announcements, at least it should support search by course_id

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/announcement**s**?param=value&...

##### Parameters

* All parameters are optional, usually are specified by default. If no parameter is given, return all.

Parameter | Value
----------|-------
*course_id* | **Required**, exactly the course id (to support announcement without course_id, use “none”)
title | Exactly the title
created_by | Exactly the creator’s email
created_from/to | The time span for created_at property
updated_from/to | The time span for updated_at property, can be used for Sync
offset | For paging, the offset index of entity for this return, default 0
limit | For paging, the numbers of entity for this return, default is unlimited?
order_by | For ordering and paging, default is order by id

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Announcement Array JSON | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Add Announcement

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/announcement**s** | Announcement JSON w/o ID

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | Announcement JSON w/ ID | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Update Announcement

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/announcement/`:id` | Announcement JSON

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Announcement JSON | Update success
400 (Bad Request) | Error JSON | ID or JSON is invalid
404 (Not Found) | Error JSON | Announcement not found
500 (Internal Server Error) | Error JSON | Other Errors

### Delete Announcement

#### Request

Method | URL | Request Body
-------|-----|-------------
DELETE | http://host:port/announcement/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

## Discussion

### Get Discussion by ID

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/discussion/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Discussion JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Discussion not found
500 (Internal Server Error) | Error JSON | Other Errors

### View Discussion by ID

#### Usage

* It will redirect to the specified discussion web view, of the service provider, show messages.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/discussion/`:id`/view

#### Response

* It should redirect to the URL of the web view for the specified discussion
using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### View Discussion List

#### Usage

* It will redirect to the discussion list web view of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/discussion**s**/view

#### Response

* It should redirect to the URL of the web view for the discussion list using
301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Search Discussions

* (Or change it to Get Discussion by Course ID?)

#### Usage

* Search for discussions, at least it should support search by course_id

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/discussion**s**?param=value&...

##### Parameters

* All parameters are optional, usually are specified by default. If no parameter is given, return all.

Parameter | Value
----------|-------
q | A part of title, description, course name (like google search)
course_id | Exactly the course id (to support discussion without course_id, use “none”)
title | Exactly the title
created_by | Exactly the creator’s email
created_from/to | The time span for created_at property
updated_from/to | The time span for updated_at property, can be used for Sync
offset | For paging, the offset index of entity for this return, default 0
limit | For paging, the numbers of entity for this return, default is unlimited?
order_by | For ordering and paging, default is order by id

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Discussion Array JSON | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Add Discussion

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/discussion**s** | Discussion JSON w/o ID

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | Discussion JSON w/ ID | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Update Discussion

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/discussion/`:id` | Discussion JSON

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Discussion JSON | Update success
400 (Bad Request) | Error JSON | ID or JSON is invalid
404 (Not Found) | Error JSON | Discussion not found
500 (Internal Server Error) | Error JSON | Other Errors

### Delete Discussion

#### Request

Method | URL | Request Body
-------|-----|-------------
DELETE | http://host:port/discussion/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

### Get Messages of a Discussion

#### Usage

* Get all messages of a discussion with paging and delta sync support.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/discussion/`:id`/messages?params...

##### Parameters

* All parameters are optional, usually are specified by default. If no parameter is given, return all.

Parameter | Value
----------|------
created_from/to | The time span for created_at property
updated_from/to | The time span for updated_at property, can be used for Sync
offset | For paging, the offset index of entity for this return, default 0
limit | For paging, the numbers of entity for this return, default is unlimited?
order_by | For ordering and paging, default is order by id or created_at?

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Message Array JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Discussion not found
500 (Internal Server Error) | Error JSON | Other Errors

### Get Message from a Discussion by ID

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/discussion/`:discussion_id`/message/`:message_id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Message JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Discussion not found
500 (Internal Server Error) | Error JSON | Other Errors

### Add Message to a Discussion

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/discussion/`:discussion_id`/message**s** | Message JSON w/o ID

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | Message JSON w/ ID | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Update Message of a Discussion

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/discussion/`:discussion_id`/message/`:message_id` | Message JSON

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Message JSON | Update success
400 (Bad Request) | Error JSON | ID or JSON is invalid
404 (Not Found) | Error JSON | Discussion not found
500 (Internal Server Error) | Error JSON | Other Errors

### Delete Message from a Discussion

#### Request

Method | URL | Request Body
-------|-----|-------------
DELETE | http://host:port/discussion/`:discussion_id`/message/`:message_id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

## Quiz

### Get Quiz by ID

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/quiz/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Quiz JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Quiz not found
500 (Internal Server Error) | Error JSON | Other Errors

### View Quiz by ID

#### Usage

* It will redirect to the specified quiz web view of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves. 
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/quiz/`:id`/view

#### Response

* It should redirect to the URL of the web view for the specified quiz using 301
(Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Search Quizzes by Course ID

#### Request

Method | URL
-------|----
GET | http://host:port/quizze**s**?course_id=`:course_id`
GET | http://host:port/course/`:course_id`/quizze**s**

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Quiz Array JSON | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Add Quiz

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/quizze**s** | Quiz JSON w/o ID

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | Quiz JSON w/ ID | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Update Quiz

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/quiz/`:id` | Quiz JSON

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Quiz JSON | Update success
400 (Bad Request) | Error JSON | ID or JSON is invalid
404 (Not Found) | Error JSON | Quiz not found
500 (Internal Server Error) | Error JSON | Other Errors

### Delete Quiz

#### Request

Method | URL | Request Body
-------|-----|-------------
DELETE | http://host:port/quiz/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

### Get Submissions of a Quiz

#### Usage

* Get submissions of a quiz with filter, paging and delta sync support.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/quiz/`:id`/submission**s**?params...

##### Parameters

* All parameters are optional, usually are specified by default. If no parameter is given, return all.

Parameter | Value | Default
----------|-------|--------
created_by | Filter by the student’s email | not specified
created_from/to | The time span for created_at property | from: not specified, to: now
updated_from/to | The time span for updated_at property, can be used for Sync | from: not specified, to: now
offset | For paging, the offset index of entity for this return | 0
limit | For paging, the numbers of entity for this return | unlimited?
order_by | For ordering and paging (use +/- to indicate ASC/DESC, + by default) | order by id or created_at?

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Submission Array JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Quiz not found
500 (Internal Server Error) | Error JSON | Other Errors

### View Submission List

#### Usage

* It will redirect to the the submission list page of specified quiz of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/quiz/`:id`/submission**s**/view

#### Response

* It should redirect to the URL of the web view for the submission list of
specified quiz using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Get Submission of a Quiz by ID

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/quiz/`:quiz_id`/submission/`:submission_id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Submission JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Quiz not found
500 (Internal Server Error) | Error JSON | Other Errors

### View Submission

#### Usage

* It will redirect to the specified submission web view of the service provider.
* It redirect to a HTML web page instead of return the JSON data. (Login may required)
* It is designed for teams depend on the service but not implement the web GUI themselves.
* It can achieved by URL rewrite.

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/discussion/`:quiz_id`/submission/`:submission_id`/view

#### Response

* It should redirect to the URL of the web view for the specified submission
using 301 (Moved Permanently) with URL in Location Header.
* If there is any error, display the error page instead.

### Add Submission for a Quiz

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/quiz/`:quiz_id`/submission**s** | Submission JSON w/o ID

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | Submission JSON w/ ID | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Update Submission for a Quiz

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/quiz/`:quiz_id`/submission/`:submission_id` | Submission JSON *

* The score will be ignored, since it designed for student if allowed, and other cannot change that.

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Submission JSON | Update success
400 (Bad Request) | Error JSON | ID or JSON is invalid
404 (Not Found) | Error JSON | Quiz not found
500 (Internal Server Error) | Error JSON | Other Errors

### Grading Submission for a Quiz

#### Usage

* Since the update submission cannot update the score,
this one is used for grading a submission

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/quiz/`:quiz_id`/submission/`:submission_id`/score | The score value

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Update success
400 (Bad Request) | Error JSON | ID or JSON is invalid
404 (Not Found) | Error JSON | Quiz not found
500 (Internal Server Error) | Error JSON | Other Errors

### Delete Submission from a Quiz

#### Request

Method | URL | Request Body
-------|-----|-------------
DELETE | http://host:port/quiz/`:quiz_id`/submission/`:submission_id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors


---

# JSON Objects

The naming convention of properties is `lowercase_separated_by_underscores` followed the same style of Ruby, Python and MongoDB.

“Python and Ruby both recommend `UpperCamelCase` for class names,
`CAPITALIZED_WITH_UNDERSCORES` for constants, and
`lowercase_separated_by_underscores` for other names.” (Wikipedia)

Every teams can extend these object for their own sake, but those extra properties may not be understandable by others.

## Success

* For methods not return an Entity JSON, e.g. delete, return this to indicate
the operation is done.
* It can be detected by both status code 2xx and whether `response_json.ok`
exists.

```
{
  ok: "OK"
  message: "Category w/ ID ... is deleted" // the readable message
}
```

## Error

* Errors can be detected by both status code 4xx/5xx and whether
`response_json.error` exists.

```
{
  error: "USER_NOT_FOUND" // The error code
  message: ""Cannot find user with email xxxxxx@xx.xxx" // the readable error message
}
```

## User

```
{
  email: // use as id
  password: // SHA-1 Hashed (lowercase, hex)
  first_name:
  last_name:
  address: (optional) {
    address:
    city:
    state:
    zip: (optional)
    country: (optional)
  }
  created_at: "2013-04-18T08:56:20.583Z" // ISO format
  updated_at: // default is the same as created_at
}
```

## Category

```
{
  id: // better to use a meaningful string
  name: // unique
  created_at: "2013-04-18T08:56:20.583Z" // ISO format (remove it if useless)
  updated_at: // default is the same as created_at (remove it if useless)
}
```

## Course

```
{
  id
  title
  description
  attachments: []
  category_id: // or we can just use the category name as its id
  participants: [{ index it or separate to another collection
    email: // user’s email
    role: // student or instructor/owner or assistant  
    status: // dropped, enrolled, etc.      
  }, ...]
  created_by: // the user who create it, and auto add to the participants as instructor/owner
  created_at: "2013-04-18T08:56:20.583Z" // ISO format
  updated_by: // user email (remove it if it is useless)
  updated_at: // default is the same as created_at
}
```

## Announcement

```
{
  id
  title
  content: // the text
  course_id
  created_by: // user email
  created_at: "2013-04-18T08:56:20.583Z" // ISO format
  updated_at: // default is the same as created_at
}
```

## Discussion

```
{
  id
  course_id: // optional, for discussion without course
  title: // optional, the topic
  created_by: // user email
  created_at: "2013-04-18T08:56:20.583Z" // ISO format
  updated_at: // default is the same as created_at
}
```

### Message

* It is separated from Discussion to avoid the size grow too big and concurrency issue.
* It depends on your team’s decision whether is should be embedded or not, but doubtful for large discussions.

```
{
  title: // optional
  content: // text
  discussion_id:
  created_by: // user email
  created_at: "2013-04-18T08:56:20.583Z" // ISO format
  updated_at: // default is the same as created_at
}
```

## Quiz

```
{
  id
  title: (optional)
  description: (optional)
  questions:[{ // Question 1..*
    content: // the content/description of the question
    options: [] // 2..*
    answer: // the correct answer
  }, ...]
  created_by: // user email
  created_at: "2013-04-18T08:56:20.583Z" // ISO format
  updated_at: // default is the same as created_at
  graded_by: // user email of who grading
  graded_at: // time of grading
}
```

### Submission

```
{
  id
  quiz_id
  score: // grading the submission for the quiz
  answers: [0,1,2,...] // for each question, keep same sequence
  created_by: // user email
  created_at: "2013-04-18T08:56:20.583Z" // ISO format
  updated_at: // default is the same as created_at
}
```

