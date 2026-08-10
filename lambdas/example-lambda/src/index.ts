// Replace me with the actual code for your Lambda function
/* eslint-disable no-console */
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
