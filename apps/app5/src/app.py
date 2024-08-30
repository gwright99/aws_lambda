def handler(event, context):
    ''' Lambda App 3 '''
    print("hello from app5!")

    expected_response = {
        "statusCode": 201,
        "headers": {
            "Content-Type": "application/json",
            "My-Custom-Header": "AP5"
        },
        "body": "{ \"message\": \"This is app5, after editing.\" }",

        "isBase64Encoded": False
    }

    print("Hello from APP5")


    return expected_response 