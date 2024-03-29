def handler(event, context):
    ''' The first function to be invoked by Lambda '''
    print("Hello from App2")

    expected_response = {
        "statusCode": 201,
        "headers": {
            "Content-Type": "application/json",
            "My-Custom-Header": "Hello from App2"
        },
        "body": "{ \"message\": \"Hello from App2!\" }",
        "cookies": [
            "Cookie_1=Value1; Expires=21 Oct 2021 07:48 GMT",
            "Cookie_2=Value2; Max-Age=78000"
        ],
        "isBase64Encoded": False
    }

    return expected_response 