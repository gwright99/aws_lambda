def handler(event, context):
    ''' Lambda App 3 '''
    print("hello from ap3!")

    expected_response = {
        "statusCode": 201,
        "headers": {
            "Content-Type": "application/json",
            "My-Custom-Header": "APP3"
        },
        "body": "{ \"message\": \"This is app3, after editing.\" }",

        "isBase64Encoded": False
    }

    print("Hello2")


    return expected_response 