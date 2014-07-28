USE MFG_Solutions
--If there is no master key, create one now. 
IF NOT EXISTS 
    (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
    CREATE MASTER KEY ENCRYPTION BY 
    PASSWORD = '23987hxJKL95QYV4369#ghf0%lekjg5k3fd117r$$#1946kcj$n44ncjhdlj'
GO

CREATE CERTIFICATE Connections
   WITH SUBJECT = 'Connection Password';
GO

CREATE SYMMETRIC KEY Passwords_Key1
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE Connections;
GO

-- Create a column in which to store the encrypted data.
ALTER TABLE [dbo].[TestEncryptions]
    ADD ConnPass varbinary(250); 
GO

-- Open the symmetric key with which to encrypt the data.
OPEN SYMMETRIC KEY Passwords_Key1
   DECRYPTION BY CERTIFICATE Connections;

-- Encrypt the value in column CardNumber using the
-- symmetric key CreditCards_Key11.
-- Save the result in column CardNumber_Encrypted.  
insert into [dbo].[TestEncryptions](ConnPass)
SELECT EncryptByKey(Key_GUID('Passwords_Key1'),  CONVERT( varbinary,'myPassword'));
GO

-- Verify the encryption.
-- First, open the symmetric key with which to decrypt the data.

OPEN SYMMETRIC KEY Passwords_Key1
   DECRYPTION BY CERTIFICATE Connections;
GO

-- Now list the original card number, the encrypted card number,
-- and the decrypted ciphertext. If the decryption worked,
-- the original number will match the decrypted number.

SELECT  convert(varchar(250),DecryptByKey(ConnPass)) AS 'Decrypted ConnPass' FROM [dbo].[TestEncryptions]
GO