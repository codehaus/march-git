################################################################################
#  Copyright 2007-2008 Codehaus Foundation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

-- Find duplicate messages

ROLLBACK;
BEGIN;

-- Look up all messages that are duplicated in a single list. If the user cross-posts; then the same
-- message_id822 will be found in different lists. This is legal (although frowned upon); the mailing list
-- should enforce rules about this.
CREATE TEMP TABLE MESSAGES_DUP ON COMMIT DROP AS
  SELECT list_id, message_id822, COUNT(*) FROM messages GROUP BY list_id, message_id822 HAVING COUNT(*) > 1;


CREATE TEMP TABLE MESSAGES_DUP_MSG ON COMMIT DROP AS
  SELECT M.id, M.list_id, M.message_id822
  FROM MESSAGES_DUP MD,
       MESSAGES M
  WHERE MD.message_id822 = M.message_id822
    AND MD.list_id = M.list_id;

-- Find anything but the lowest; prints using a format that can be used to destroy the messages in Rails
SELECT 'Message.destroy(' || MDM.id || ')'
FROM MESSAGES_DUP_MSG MDM
WHERE MDM.id > ( SELECT MIN(id) 
                 FROM MESSAGES_DUP_MSG MDMI
                 WHERE MDMI.list_id = MDM.list_id
                   AND MDMI.message_id822 = MDM.message_id822
               );



ROLLBACK;
