package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/codebuild"
	"log"
)

type Response events.APIGatewayProxyResponse

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (Response, error) {
	diffID := request.QueryStringParameters["diff_id"]
	phid := request.QueryStringParameters["phid"]
	revisionID := request.QueryStringParameters["revision_id"]
	fmt.Printf("diff_id: %s, phid: %s, revision_id: %s\n", diffID, phid, revisionID)

	header, ok := request.Headers["Authorization"]
	if ok {
		fmt.Printf("auth header is: %s\n", header)
	} else {
		fmt.Printf("auth header is not set\n")
	}

	requestJSON, _ := json.MarshalIndent(request, "", "  ")
	log.Printf("EVENT: %s", requestJSON)

	session := session.Must(session.NewSession())

	svc := codebuild.New(session)

	input := &codebuild.StartBuildInput{
		ProjectName: aws.String("example-project-api-gateway-trigger"),
		EnvironmentVariablesOverride: []*codebuild.EnvironmentVariable{
			{
				Name:  aws.String("DIFF_ID"),
				Value: aws.String(diffID),
			},
			{
				Name:  aws.String("PHID"),
				Value: aws.String(phid),
			},
			{
				Name:  aws.String("REVISION_ID"),
				Value: aws.String(revisionID),
			},
		},
	}

	result, err := svc.StartBuild(input)
	if err != nil {
		log.Fatal(err)
		return Response{StatusCode: 500}, err
	}

	return Response{
		StatusCode: 200,
		Body:       fmt.Sprintf("diff_id: %s, phid: %s, revision_id: %s build_id: %s\n", diffID, phid, revisionID, *result.Build.Id),
	}, nil
}

func main() {
	lambda.Start(handler)
}
