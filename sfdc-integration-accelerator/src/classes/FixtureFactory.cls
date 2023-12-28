/**
 * @description: Fixture Factory for test classes
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class FixtureFactory {

    private static Integer idCountForTest = 1;

    public static String generateFakeId(Schema.SObjectType sobjectType) {

        String result = String.valueOf(idCountForTest++);

        return sobjectType.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }
}