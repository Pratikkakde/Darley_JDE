/**
 * Created by piotr harbunou on 6/23/2023
 * generate keys:
 *     openssl command: openssl genrsa -des3 -out private.pem 512
 *     openssl command: openssl rsa -in private.pem -noout -text
 *
 *     MODULE is 'modulus' (remove colons, remove 00 prefix and make into single line)
 *     PUBLIC_EXPONENT is 'publicExponent' (remove 0x = 10001)
 *     PRIVATE_EXPONENT is 'privateExponent' (remove colons and make into single line)
 */

public with sharing class B2BRSA {
    public static String MODULE = 'e9e612c4e2810f9e21a302375f454b54886cabe9f50a72fea7c7f5aecf7707188e9933edd9f20329facb8f9dbc3003966ade9ad270e3a67d5d8a91e81b750659';
    public static String PUBLIC_EXPONENT = '10001';
    private static String PRIVATE_EXPONENT = '5bf09d161936c40dd38900d90530f6d06ea3d0dbb0ff7f7e4c3354867774812bcc925ee21d191c952880b7a7b5c7a14c5b95f4a00362188546c8b5ee7a60de11';

    private static final String DIGITS = '0123456789abcdef';
    private static final Decimal HEX_BASE = 16;

    public String encrypt(String input) {
        return modPowEncrypt(input, MODULE, PUBLIC_EXPONENT);
    }

    public String decrypt(String input) {
        Blob encodedData = EncodingUtil.convertFromHex(input);
        return modPowDecrypt(EncodingUtil.base64Encode(encodedData), MODULE, PRIVATE_EXPONENT);
    }

    public String modPowEncrypt(String input, String modulus, String exponent) {
        Blob pn = Blob.valueOf(input);

        Decimal pnDec = hexToDecimal(EncodingUtil.convertToHex(pn));
        Decimal modDec = hexToDecimal(modulus);
        Decimal expDec = hexToDecimal(exponent);

        Decimal result = modPow(pnDec, expDec, modDec);
        String hexResult = decimalToHex(result);
        if ((hexResult.length() & 1) == 1) {
            hexResult = '0' + hexResult;
        }

        return hexResult;
    }

    public String modPowDecrypt(String input, String modulus, String exponent ) {
        Blob pn = EncodingUtil.base64Decode(input);

        Decimal pnDec = hexToDecimal(EncodingUtil.convertToHex(pn));
        Decimal modDec = hexToDecimal(modulus);
        Decimal expDec = hexToDecimal(exponent);

        Decimal result = modPow(pnDec, expDec, modDec);
        String hexResult = decimalToHex(result);
        if ((hexResult.length() & 1) == 1) {
            hexResult = '0' + hexResult;
        }

        String temp = blobToString(hexResult, 'UTF-8');
        return temp;
    }

    public static String blobToString(String hex, String inCharset) {
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for (Integer i = 0; i < bytesCount; ++i) {
            bytes[i] = hex.mid(i << 1, 2);
        }

        for (Integer i = bytesCount-1; i >= 0; i--) {
            if (bytes[i].equals('00')) {
                List<String> bytesTemp = new List<String>();

                for(Integer j = i; j < bytesCount; j++) {
                    bytesTemp.add(bytes[j]);
                }

                bytes = bytesTemp;
                break;
            }
        }

        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }

    private static Decimal hexToDecimal(String hex) {
        Decimal result = 0;
        Integer length = hex.length();
        Integer i = 0;
        while(i < length) {
            Integer hexByte = DIGITS.indexOf(hex.substring(i, i + 1).toLowerCase());
            i++;
            result += hexByte * HEX_BASE.pow(length - i);
        }
        return result;
    }

    private static String decimalToHex(Decimal d) {
        String hex = '';
        while (d > 0) {
            Decimal digit = modulus(d, HEX_BASE);
            hex = DIGITS.substring(digit.intValue(), digit.intValue() + 1) + hex;
            d = d.divide(16, 0, RoundingMode.FLOOR);
        }
        return hex;
    }

    private static Decimal modPow(Decimal base, Decimal exp, Decimal mod) {
        if (base < 1 || exp < 0 || mod < 1) {
            return -1;
        }

        Decimal result = 1;
        while (exp > 0) {
            if ((exp.longValue() & 1) == 1) {
                result = modulus((result * base), mod);
            }
            base = modulus((base * base), mod);
            exp = exp.divide(2, 0, RoundingMode.FLOOR);
        }
        return result;
    }

    private static Decimal modulus(Decimal dividend, Decimal divisor) {
        Decimal d = dividend.divide(divisor, 0, RoundingMode.FLOOR);
        return dividend - (d * divisor);
    }

}