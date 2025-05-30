// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/file;
import ballerina/ftp;
import ballerina/io;
import ballerina/log;
import ballerinax/financial.swiftmtToIso20022 as mtToMx;

configurable string mtfilepath = "/mt/";
configurable string mtfileNamePattern = "(.*).txt";

// Creates the listener with the connection parameters and the protocol-related
// configuration. The listener listens to the files
// with the given file name pattern located in the specified path.
listener ftp:Listener mtFileListener = new ({
    host: hostname,
    port: port,
    auth: ftpListenerAuthConfig,
    path: mtfilepath,
    fileNamePattern: mtfileNamePattern,
    pollingInterval: pollingInterval
});

// One or many services can listen to the SFTP listener for the
// periodically-polled file related events.
service on mtFileListener {

    // When a file event is successfully received, the `onFileChange` method is called.
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {

        // `addedFiles` contains the paths of the newly-added files/directories after the last polling was called.
        foreach ftp:FileInfo addedFile in event.addedFiles {

            log:printDebug(string `[FTP MT Listner - ${listenerName}] File received: ${addedFile.name}`);
            // Get the newly added file from the SFTP server as a `byte[]` stream.
            stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
            // Delete the file from the SFTP server after reading.
            check caller->delete(addedFile.pathDecoded);

            // copy to local file system
            check io:fileWriteBlocksFromStream(string `./temp/${addedFile.name}`, fileStream);
            check fileStream.close();

            // performs a read operation to read the lines as an array.
            string swiftMessage = check io:fileReadString(string `./temp/${addedFile.name}`);

            xml|error transformedMsg = mtToMx:toIso20022Xml(swiftMessage);
            [string, string, string, string, string] [msgId, mtMsgType, msgDirection, msgCcy, msgAmnt] = 
                check getMtMessageInfo(swiftMessage);
            if transformedMsg is error {
                logMessage(swiftMessage, "", msgId, msgDirection, mtMsgType, DEFAULT,
                    msgCcy, msgAmnt, transformedMsg.toBalString());
                log:printError("Error while transforming MT message", err = transformedMsg.toBalString());
            } else {
                string mxMsgType = check getMxMessageType(transformedMsg);
                logMessage(swiftMessage, transformedMsg.toBalString(), msgId, msgDirection, mtMsgType, mxMsgType,
                    msgCcy, msgAmnt);
                string outputFileName = string `/result_${addedFile.name.substring(0, addedFile.name.length() - 4)}_${msgId}.xml`;
                check fileClient->put(outputFilePath + outputFileName, transformedMsg);
            }
            // remove temporary file
            check file:remove(string `./temp/${addedFile.name}`);
            // Write the content to a file.
            check caller->put(backupFilePath + msgId + "_" + addedFile.name, swiftMessage);
        }
    }

    function init() {
        log:printDebug(string `[FTP MT Listner - ${listenerName}] Listener started.`);
    }
}
