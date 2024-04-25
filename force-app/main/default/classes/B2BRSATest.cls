/**
 * Created by piotr harbunou on 6/23/2023.
 */

@IsTest
private class B2BRSATest {

    @IsTest
    static void checkEncrypting() {
        B2BRSA rsaForEncrypt = new B2BRSA();
        String message = 'Hello World';
        String encryptedMessage = rsaForEncrypt.encrypt(message);
        System.assert(encryptedMessage != null, 'Encrypted message should exist');

        B2BRSA rsaForDecrypt = new B2BRSA();
        String decryptedMessage = rsaForDecrypt.decrypt(encryptedMessage);
        System.assert(decryptedMessage != null, 'Encrypted message should exist');
        System.assertEquals(decryptedMessage, message, 'Encrypted message not equal original message');
    }

}