def handler(event, context):
    ''' The first function to be invoked by Lambda '''
    print("hello from app1!")

    expected_response = {
        "statusCode": 201,
        "headers": {
            "Content-Type": "application/json",
            "My-Custom-Header": "Custom Value"
        },
        "body": "{ \"message\": \"Hello, world!\" }",
        "cookies": [
            "Cookie_1=Value1; Expires=21 Oct 2021 07:48 GMT",
            "Cookie_2=Value2; Max-Age=78000"
        ],
        "isBase64Encoded": False
    }

    print("Hello2")
    print("Hello3")
    print("Hello31")
    print("Hello HTTPRoute short URL")

    return expected_response 