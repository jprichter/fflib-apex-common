/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs, PMD.ApexDoc, PMD.ClassNamingConventions')
public class fflib_SObjectsTest
{
    private static Integer testFakeIdSequence = 0;
    private static final String TEST_FAKE_ID_PADDING = '000000000000';

    /**
     * Returns a syntactically valid fake Id for the given SObject type. For unit tests only
     * (same scheme historically provided by fflib_IDGenerator in ApexMocks).
     *
     * @param sobjectType The type whose key prefix the fake Id should use
     */
    @TestVisible
    private static Id generateTestRecordId(Schema.SObjectType sobjectType)
    {
        String keyPrefix = fflib_SObjectDescribe.getDescribe(sobjectType).getDescribe().getKeyPrefix();
        testFakeIdSequence++;
        String prefix = TEST_FAKE_ID_PADDING.substring(
            0,
            TEST_FAKE_ID_PADDING.length() - String.valueOf(testFakeIdSequence).length()
        );
        return Id.valueOf(keyPrefix + prefix + testFakeIdSequence);
    }

    @IsTest
    static void itShouldClearTheField()
    {
        Account record = new Account(ShippingCountry = 'Holland');
        DomainAccounts domain = new DomainAccounts(new List<Account>
        {
record
        }
);
        System.assert(!domain.selectByShippingCountry('Holland').isEmpty(), 'Incorrect test data');

        domain.clearField(Schema.Account.ShippingCountry);

        System.assert(domain.selectByShippingCountry('Holland').isEmpty(), 'Field should have been nullified');
    }

    @IsTest
    static void itShouldReturnTheDomainsType()
    {
        System.assertEquals(
                (Object) Schema.Account.SObjectType,
                new DomainAccounts(new List<Account>())
                        .getType(),
                'Unexpected Domain Type'
        );
        System.assertEquals(
                Schema.Account.SObjectType,
                new DomainAccounts(new List<Account>())
                        .getSObjectType(),
                'Unexpected Domain SObjectType'
        );
    }


    @IsTest
    static void itShouldReturnRecordsIds()
    {
        SObjectType accountSObjectType = Schema.Account.SObjectType;
        Id idA = generateTestRecordId(accountSObjectType);
        Id idB = generateTestRecordId(accountSObjectType);
        Id idC = generateTestRecordId(accountSObjectType);

        DomainAccounts domain = new DomainAccounts(
                new List<SObject>
                {
                        new Account(Id = idA),
                        new Account(Id = idB),
                        new Account(Id = idC)
                }
        );

        Set<Id> recordIds = new Set<Id>
        {
idA, idB, idC
        }
;
        System.assert(
                domain.getRecordIds().equals(recordIds),
                'The domain should return all the record Ids'
        );

        System.assert(
                domain.getIdFieldValues(Schema.Account.Id).equals(recordIds),
                'The domain should return all the record Ids'
        );
    }

    @IsTest
    static void itShouldReturnRecordsWithFieldValues()
    {
        DomainAccounts domain = generateDomain();

        System.assert(domain.selectByShippingCountry('USA').size() == 1, 'it Should Return Records With Field Values should satisfy domain.selectByShippingCountry(USA).size() == 1');
    }

    @IsTest
    static void itShouldReturnRecordsWithoutFieldValues()
    {
        DomainAccounts domain = generateDomain();

        System.assertEquals(3, domain.selectWithoutShippingCountry().size(), 'it Should Return Records Without Field Values should produce 3');
    }
    @IsTest
    static void itShouldReturnRecordsWithoutFieldValuesForNonStringFields()
    {
        DomainAccounts domain = generateDomain();

        System.assertEquals(4, domain.selectWithoutNumberOfEmployees().size(), 'it Should Return Records Without Field Values For Non String Fields should produce 4');
    }

    @IsTest
    static void itShouldReturnRecordsWithoutAllFieldValues()
    {
        DomainAccounts domain = generateDomain();

        System.assert(domain.selectWithEmptyRecord().size() == 1, 'it Should Return Records Without All Field Values should satisfy domain.selectWithEmptyRecord().size() == 1');
    }

    @IsTest
    static void itShouldReturnRecordsWithShippingCountry()
    {
        DomainAccounts domain = generateDomain();

        System.assert(domain.selectWithShippingCountry().size() == 4, 'it Should Return Records With Shipping Country should satisfy domain.selectWithShippingCountry().size() == 4');
    }
    @IsTest
    static void itShouldReturnRecordsWithNumberOfEmployees()
    {
        DomainAccounts domain = generateDomain();

        System.assert(domain.selectWithNumberOfEmployees().size() == 3, 'it Should Return Records With Number Of Employees should satisfy domain.selectWithNumberOfEmployees().size() == 3');
    }

    @IsTest
    static void itShouldReturnRecordsWithAllFieldValues()
    {
        DomainAccounts domain = generateDomain();

        System.assert(domain.selectPopulatedRecords().size() == 2, 'it Should Return Records With All Field Values should satisfy domain.selectPopulatedRecords().size() == 2');
    }

    @IsTest
    static void itShouldReturnFieldValues()
    {
        DomainAccounts domain = generateDomain();

        final Set<String> expected = new Set<String>
        {
                null,
                '',
                'Canada',
                'Ireland',
                'UK',
                'USA'
        }
;
        System.assert(
                domain.getStringFieldValues(Schema.Account.ShippingCountry).equals(expected)
        , 'it Should Return Field Values should satisfy domain.getStringFieldValues(Schema.Account.ShippingCountry).equals(ex...');

        System.assert(
                domain.getFieldValues(Schema.Account.ShippingCountry)
                        .equals(expected)
        , 'it Should Return Field Values should satisfy domain.getFieldValues(Schema.Account.ShippingCountry) .equals(expected)');
    }

    @IsTest
    static void itShouldReturnFieldValuesForNonStringFields()
    {
        DomainAccounts domain = generateDomain();

        final Set<Integer> expectedOriginalType = new Set<Integer>
        {
                null,
                10,
                20,
                30
        }
;

        System.assert(
                domain.getFieldValues(Schema.Account.NumberOfEmployees)
                        .equals(expectedOriginalType)
        , 'it Should Return Field Values For Non String Fields should satisfy domain.getFieldValues(Schema.Account.NumberOfEmployees) .equals(expec...');
    }

    @IsTest
    static void getStringFieldValuesShouldThrowClassCastExceptionForNonStringFields()
    {
        DomainAccounts domain = generateDomain();

        try
        {
            domain.getStringFieldValues(Schema.Account.NumberOfEmployees);
            Assert.fail('Expected ClassCastException because NumberOfEmployees is not a Text field');
        }
        catch (System.TypeException expected)
        {
            System.assert(expected.getMessage().contains('Invalid conversion from runtime type'),
                    'Unexpected exception message: ' + expected.getMessage());
        }
    }

    @IsTest
    static void itShouldSetFieldValue()
    {
        DomainAccounts domain = generateDomain();
        String country = 'Holland';
        domain.setShippingCountry(country);

        System.assert(domain.selectByShippingCountry(country).size() == 7, 'it Should Set Field Value should satisfy domain.selectByShippingCountry(country).size() == 7');
    }


    @IsTest
    static void itShouldSetFieldValueByCondition()
    {
        DomainAccounts domain = generateDomain();
        domain.setRatingByShippingCountry(
                new Map<Object,Object>
                {
                        'USA' => 'Hot'
                }
        );

        System.assert(domain.selectByRating('Hot').size() == 1, 'it Should Set Field Value By Condition should satisfy domain.selectByRating(Hot).size() == 1');
    }

    @IsTest
    static void itShouldAllowBulkMutatorsFromOutsideDomainHierarchy()
    {
        Account recordA = new Account(Name = 'A', ShippingCountry = 'USA');
        Account recordB = new Account(Name = 'B', ShippingCountry = 'Canada');
        DomainAccounts domain = new DomainAccounts(new List<Account>
        {
recordA, recordB
        }
);

        domain.addError('Bulk record error');
        domain.addError(Schema.Account.Name, 'Bulk field error');
        domain.clearFields(new Set<Schema.SObjectField>
        {
Schema.Account.ShippingCountry
        }
);

        System.assertEquals(2, domain.getRecords().size(), 'it Should Allow Bulk Mutators From Outside Domain Hierarchy should produce 2');
        System.assertEquals(null, recordA.ShippingCountry, 'it Should Allow Bulk Mutators From Outside Domain Hierarchy should produce null');
        System.assertEquals(null, recordB.ShippingCountry, 'it Should Allow Bulk Mutators From Outside Domain Hierarchy should produce null');
    }

    @IsTest
    static void testDomainErrorLogging()
    {
        // Test static helpers for raise none domain object instance errors
        final String errorMessage = 'Test Error';
        Account record = new Account();
        DomainAccounts domain = new DomainAccounts(new List<Account>
        {
record
        }
);
        domain.addNameError(errorMessage);

        System.assertEquals(1, fflib_SObjects.Errors.getAll().size(), 'test Domain Error Logging should produce 1');
        System.assertEquals(errorMessage, fflib_SObjects.Errors.getAll()[0].message, 'test Domain Error Logging should produce errorMessage');
        System.assertEquals(Account.Name, ((fflib_SObjects.FieldError) fflib_SObjects.Errors.getAll()[0]).field, 'test Domain Error Logging should produce Account.Name');
    }

    @IsTest
    static void testErrorLogging()
    {
        // Test static helpers for raise none domain object instance errors
        Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
        fflib_SObjects.Errors.error('Error', opp);
        fflib_SObjects.Errors.error('Error', opp, Opportunity.Type);
        System.assertEquals(2, fflib_SObjects.Errors.getAll().size(), 'test Error Logging should produce 2');
        System.assertEquals('Error', fflib_SObjects.Errors.getAll()[0].message, 'test Error Logging should produce Error');
        System.assertEquals('Error', fflib_SObjects.Errors.getAll()[1].message, 'test Error Logging should produce Error');
        System.assertEquals(Opportunity.Type, ((fflib_SObjects.FieldError) fflib_SObjects.Errors.getAll()[1]).field, 'test Error Logging should produce Opportunity.Type');
        fflib_SObjects.Errors.clearAll();
        System.assertEquals(0, fflib_SObjects.Errors.getAll().size(), 'test Error Logging should produce 0');
    }

    private static DomainAccounts generateDomain()
    {
        DomainAccounts domain = new DomainAccounts(
                new List<Account>
                {
                        new Account(Name = 'A', ShippingCountry = 'USA'),
                        new Account(Name = 'B', ShippingCountry = 'Ireland'),
                        new Account(Name = 'C', ShippingCountry = 'UK', NumberOfEmployees = 10),
                        new Account(Name = 'D', ShippingCountry = ''),
                        new Account(Name = 'E', NumberOfEmployees = 20),
                        new Account(),
                        new Account(Name = 'G', ShippingCountry = 'Canada', NumberOfEmployees = 30)
                }
        );
        return domain;
    }


    private class DomainAccounts extends fflib_SObjects
    {
        public DomainAccounts(List<SObject> records)
        {
            super(records, Schema.Account.SObjectType);
        }

        public List<Account> selectByShippingCountry(String country)
        {
            return (List<Account>) getRecordsByFieldValues(
                Schema.Account.ShippingCountry,
                new Set<Object>
                {
country
                }
            );
        }

        public List<Account> selectByRating(String rating)
        {
            return (List<Account>) getRecordsByFieldValue(
                Schema.Account.Rating,
                    rating
            );
        }

        public List<Account> selectWithoutShippingCountry()
        {
            return (List<Account>) getRecordsWithBlankFieldValues(
                            Schema.Account.ShippingCountry
            );
        }

        public List<Account> selectWithShippingCountry()
        {
            return (List<Account>) getRecordsWithNotBlankFieldValues(
                            Schema.Account.ShippingCountry
            );
        }

        public List<Account> selectWithoutNumberOfEmployees()
        {
            return (List<Account>) getRecordsWithBlankFieldValues(
                            Schema.Account.NumberOfEmployees
            );
        }

        public List<Account> selectWithNumberOfEmployees()
        {
            return (List<Account>) getRecordsWithNotBlankFieldValues(
                            Schema.Account.NumberOfEmployees
            );
        }

        public List<Account> selectWithEmptyRecord()
        {
            return (List<Account>) getRecordsWithAllBlankFieldValues(
                    new Set<Schema.SObjectField>
                    {
                            Schema.Account.Name,
                            Schema.Account.ShippingCountry,
                            Schema.Account.NumberOfEmployees
                    }
            );
        }

        public List<Account> selectPopulatedRecords()
        {
            return (List<Account>) getRecordsWithAllNotBlankFieldValues(
                    new Set<Schema.SObjectField>
                    {
                            Schema.Account.Name,
                            Schema.Account.ShippingCountry,
                            Schema.Account.NumberOfEmployees
                    }
            );
        }

        public void setShippingCountry(String country)
        {
            setFieldValue(Schema.Account.ShippingCountry, country);
        }

        public void setRatingByShippingCountry(Map<Object, Object> ratingByCountry)
        {
            setFieldValueByMap(
                    Schema.Account.ShippingCountry,
                    Schema.Account.Rating,
                    ratingByCountry);
        }

        public void addNameError(String message)
        {
            addError(Schema.Account.Name, message);
        }

        public void clearShippingCountry()
        {
            clearField(Schema.Account.ShippingCountry);
        }
    }
}
