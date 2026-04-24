// Replace me with the actual code for your Lambda function
export const handler = async (
  event: Record<string, unknown>,
): Promise<{
  statusCode: number;
  body: string;
}> => {
  console.log("Received event:", event);
  return {
    statusCode: 200,
    body: "Event logged",
  };
};
