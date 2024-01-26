def lambda_handler(event, context):
    import boto3
    import json
    print(event)

    # Extract job information from the event
    job_id = event['CodePipeline.job']['id']

    # Update the ECR image for the target Lambda function
    pay_load = event['CodePipeline.job']['data']['actionConfiguration']['configuration']['UserParameters']
    pay_load = json.loads(pay_load)
    lambda_client = boto3.client('lambda')
    codepipeline = boto3.client('codepipeline')
    try:
        response = lambda_client.update_function_code(
            FunctionName=pay_load['FunctionName'],
            ImageUri=pay_load['ecrImage']
        )
        print(response)
        if response['ResponseMetadata']['HTTPStatusCode']==200:  
            # Update the job status to success
            print("job success")     
            codepipeline.put_job_success_result(jobId=job_id)
        else:
            print("job failed")
            codepipeline.put_job_failure_result(
                jobId=job_id,
                failureDetails={
                    'type': 'JobFailed',
                    'message': str(response)
                })
        return response
    except Exception as error:
        print("job failed")
        codepipeline.put_job_failure_result(
            jobId=job_id,
            failureDetails={
                'type': 'JobFailed',
                'message': str(error)
            })

    
