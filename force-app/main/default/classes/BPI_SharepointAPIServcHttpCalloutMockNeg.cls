/*****************************************************************************************
*       Date:        4NOV2019
*       Author:      Naglis Kazlauskas - IBM
*       Description: HttpCallout Mock for BPI_SharepointAPIService
*****************************************************************************************/
@isTest
global class BPI_SharepointAPIServcHttpCalloutMockNeg implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest request) {
		HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type','multipart/form-data;boundary=----------------------------153501500631101');
        response.setHeader('BaseFolderName','baseFolder');
        response.setHeader('CounterpartyId','subFolder');
        response.setBody('{"error":["myTest1", "myTest2"], "access_token":"1"}');
        response.setStatusCode(400);
        return response;         
    }
}