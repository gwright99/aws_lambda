def handler(event, context):
    ''' Lambda App 3 '''
    print("hello from app6!")

    expected_response = {
        "statusCode": 201,
        "headers": {
            "Content-Type": "application/json",
            "My-Custom-Header": "APP6"
        },
        "body": "{ \"message\": \"This is ap6, after editing.\" }",

        "isBase64Encoded": False
    }

    print("Hello from APP6")


    return expected_response 