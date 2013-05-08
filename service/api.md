RESTful API (Draft)
===========

-- Proposed by Wilson (Yufan) Yang <yyfearth@gmail.com>

Some principals I followed:

1. Stateless - no session is stored
2. Represents as Resources/Services (Nouns) instead of Actions (Verbs)
3. Use single noun for resource deal with a single entity (e.g. get by ID, update and delete), use  for a set of entities (e.g. create and search/list)
4. Using lowercase_separated_by_underscores followed the naming convention of Ruby, Python and MongoDB  
5. Using standard [HTTP Status Code](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) to indicate the results

**Some requirements:**

1. Use JSON as the format for the body of both request and response.
2. For all response, there should be a header: `Content-Type: application/json; charset=utf-8`.
3. When creating entity, the API must return 201 with created entity’s JSON, and the URL with its ID in the `Location` Header.
4. All get by ID method support GET and HEAD method, while using HEAD it should return the same status code as GET but without content.
5. For most entities, use POST to create, PUT to update, GET to query and DELETE to remove.
6. For some APIs does not return entity(ies), it should return a Success JSON to indicate it success, and all exception should return a proper Status Code (400 for Bad Request, 404 for Not Found, 500 for Internal Error, etc.) with a Error JSON.
7. Search parameter `order_by`, use `field_name.asc/desc`, `asc` by default, e.g. `created_by`, `updated_by.desc`.

**ATTENTION:**
Since the RESTful API should be only used for Web Server not for Clients (in browser), your web server should take care of all responsibility for security and privacy issues.
DO NOT ALLOW clients directly access the API without go through your web server.

---

## User

### User Validation (Deprecated)

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

#### Request

Method | URL
-------|----
GET | http://host:port/user/`:email`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | User JSON | Success
400 (Bad Request) | Error JSON | Email is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

### Search Users

Method | URL
-------|----
GET | http://host:port/user**s**?param=value&...

####Parameters

* All parameters are optional, usually are specified by default.

Parameter | Value | Default
----------|-------|--------
created_from/to | The time span for created_at property | -
updated_from/to | The time span for updated_at property, can be used for Sync | -
offset | For paging, the offset index of entity for this return | 0
limit | For paging, the numbers of entity for this return | 20
order_by | For ordering and paging (use field_name.asc/desc) | id.asc

#### Response
Status Code | Response Body | Condition
200 (OK) | User Array JSON | Success
500 (Internal Server Error) | Error JSON | Other Errors

### Create User

#### Usage

* Create a new user for user registration.
* The password should be always hashed by SHA-1, lower-cased hex string.

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/user**s** | User JSON

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | User JSON | Success
409 (Conflict) | Error JSON | Email is duplicated
500 (Internal Server Error) | Error JSON | Other Errors

### Save User

#### Usage

* Can be used for both creating and updating user, since the email address is unique.
* Email cannot be changed since it is the ID

#### Request

Method | URL | Request Body
-------|-----|-------------
PUT | http://host:port/user/`:email` | User JSON *

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
201 (Created) | User JSON | Create new user if not exists
200 (OK) | User JSON | Update existing user
400 (Bad Request) | Error JSON | Email or JSON is invalid
500 (Internal Server Error) | Error JSON | Other Errors

### Delete User (Optional)

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

### Search Categories

#### Request

Method | URL
-------|----
GET | http://host:port/categor**ies**

#### Parameters

* All parameters are optional, usually are specified by default.
* Return all categories when no parameter is given, since the object is small, and it will not be too many in total.

Parameter | Value | Default
----------|-------|--------
q | A part of name | -
name | Exactly the name | -
created_from/to | The time span for created_at property | -
updated_from/to | The time span for updated_at property, can be used for Sync | -
offset | For paging, the offset index of entity for this return | 0
limit | For paging, the numbers of entity for this return | **No limit**
order_by | For ordering and paging (use field_name.asc/desc) | id.asc

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

### Update Category (Optional)

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

### Delete Category (Optional)

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

### Search Courses

#### Request

Method | URL
-------|----
GET | http://host:port/course**s**?param=value&...

##### Parameters

* All parameters are optional, usually are specified by default. If no parameter is given, return all.

Parameter | Value | Default
----------|-------|--------
q | A part of title, description, category, etc. (like google search) | -
title | Exactly the title | -
category_id | Exactly the category | -
participant_email | One of the participants’ email | -
created_by | Exactly the creator’s email | -
created_from/created_to | The time span for created_at property | -
updated_from/updated_to | The time span for updated_at property, can be used for Sync | -
offset | For paging, the offset index of entity for this return | 0
limit | For paging, the numbers of entity for this return | 20
order_by | For ordering and paging (use field_name.asc/desc) | id.asc

##### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Course Array JSON | Success
500 (Internal Server Error) | Error JSON | Other Errors

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

Method | URL
-------|----
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
* It will return all user entities **without additionally attribute like role**.

#### Request

Method | URL
-------|----
GET | http://host:port/course/`:id`/participant**s**

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | User Array JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Course not found
500 (Internal Server Error) | Error JSON | Other Errors

### Enroll Course

#### Request

Method | URL | Request Body
-------|-----|-------------
POST | http://host:port/course/`:course_id`/participant**s** | Participant JSON (Required)
PUT | http://host:port/course/`:course_id`/participant/`:email` | Participant JSON (Optional)

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | Email or ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

### Drop Course

#### Request

Method | URL
-------|----
DELETE | http://host:port/course/`:course_id`/participant/`:email`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Success JSON | Delete success
400 (Bad Request) | Error JSON | Email or ID is invalid
404 (Not Found) | Error JSON | User not found
500 (Internal Server Error) | Error JSON | Other Errors

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

### Search Announcements

#### Usage

* Search for announcements, at least it should support search by `course_id`
* Support `update_from/to` will enable the ability for synchronize

#### Request

Method | URL | Request Body
-------|-----|-------------
GET | http://host:port/announcement**s**?param=value&...

##### Parameters

* All parameters are optional, usually are specified by default. If no parameter is given, return all.

Parameter | Value | Default
----------|-------|--------
*course_id* | **Required**, exactly the course id (to support announcement without course_id, use “none”) | -
title | Exactly the title | -
created_by | Exactly the creator’s email | -
created_from/to | The time span for created_at property | -
updated_from/to | The time span for updated_at property, can be used for Sync | -
offset | For paging, the offset index of entity for this return | 0
limit | For paging, the numbers of entity for this return | 20
order_by | For ordering and paging (use field_name.asc/desc) | id.asc

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

Method | URL
-------|-----
GET | http://host:port/discussion/`:id`

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Discussion JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Discussion not found
500 (Internal Server Error) | Error JSON | Other Errors

### Get Discussion by Course ID

#### Request

Method | URL
-------|-----
GET | http://host:port/discussion/course/`:course_id`
GET | http://host:port/course/`:course_id`/discussion

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Discussion JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Discussion not found
500 (Internal Server Error) | Error JSON | Other Errors

### Search Discussions

* (Or change it to Get Discussion by Course ID?)

#### Usage

* Search for discussions, at least it should support search by course_id

#### Request

Method | URL
-------|----
GET | http://host:port/discussion**s**?param=value&...

##### Parameters

* All parameters are optional, usually are specified by default.

Parameter | Value | Default
----------|-------|--------
q | A part of title, description, course name (like google search) | -
course_id | Exactly the course id (to support discussion without course_id, use “none”) | -
title | Exactly the title | -
created_by | Exactly the creator’s email | -
created_from/to | The time span for created_at property | -
updated_from/to | The time span for updated_at property, can be used for Sync | -
offset | For paging, the offset index of entity for this return | 0
limit | For paging, the numbers of entity for this return | 20
order_by | For ordering and paging | id.asc

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

### Delete Discussion (Optional)

#### Request

Method | URL
-------|----
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

Method | URL
-------|----
GET | http://host:port/discussion/`:discussion_id`/messages?params...

##### Parameters

* All parameters are optional, usually are specified by default.

Parameter | Value
----------|------
created_from/to | The time span for created_at property | -
updated_from/to | The time span for updated_at property, can be used for Sync | -
offset | For paging, the offset index of entity for this return | 0
limit | For paging, the numbers of entity for this return | 20
order_by | For ordering and paging | id.asc or created_at.desc?

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

### Update Message of a Discussion (Optional)

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

### Delete Message from a Discussion (Optional)

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
order_by | For ordering and paging (use +/- to indicate ASC/DESC, + by default) | id.asc or created_at.desc?

#### Response

Status Code | Response Body | Condition
------------|---------------|----------
200 (OK) | Submission Array JSON | Success
400 (Bad Request) | Error JSON | ID is invalid
404 (Not Found) | Error JSON | Quiz not found
500 (Internal Server Error) | Error JSON | Other Errors

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

### Update Submission for a Quiz (Optional)

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

### Delete Submission from a Quiz (Optional)

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
  message: "Category ... is deleted" // the readable message
}
```

## Error

* Errors can be detected by both status code 4xx/5xx and whether
`response_json.error` exists.

```
{
  error: "USER_NOT_FOUND" // The error code
  message: "Cannot find user 'xxxxxx@xx.xxx'" // the readable error message
}
```

## User

```
{
  email: // use as id
  password: // SHA-1 Hashed (lowercase, hex)
  first_name:
  last_name:
  address: (optional) { // Address
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
  participants: [{ // Participant, index its email or separate to another collection
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
  course_id
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
  note: // some comments
  score: // grading the submission for the quiz
  answers: [0,1,2,...] // for each question, keep same sequence
  created_by: // user email
  created_at: "2013-04-18T08:56:20.583Z" // ISO format
  updated_at: // default is the same as created_at
}
```
