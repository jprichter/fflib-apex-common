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

/**
    This class adapted from https://github.com/capeterson/Apex-Util
    Used under a BSD license: https://github.com/capeterson/Apex-Util/blob/master/LICENSE
**/
@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs, PMD.ClassNamingConventions, PMD.MethodNamingConventions')
private class fflib_SObjectDescribeTest
{

    /**
     * Verify that the different ways of getting your hands on an fflib_SObjectDescribe instance all handle null inputs
     * (and blank/empty strings, why not?) by returning null - since there's no possible way to resolve it.
    **/
    @IsTest
    static void getDescribe_badInput()
    {
        String nullStr = null; //having it as a string var makes for unambiguous selection of overloads
        Schema.SObjectType nullType = null;
        Schema.DescribeSObjectResult nullDescribe = null;
        SObject nullSObject = null;
        System.assertEquals(null, fflib_SObjectDescribe.getDescribe(nullStr), 'get Describe bad Input should produce null');
        System.assertEquals(null, fflib_SObjectDescribe.getDescribe(''), 'get Describe bad Input should produce null');
        System.assertEquals(null, fflib_SObjectDescribe.getDescribe(' '), 'get Describe bad Input should produce null');
        System.assertEquals(null, fflib_SObjectDescribe.getDescribe(nullType), 'get Describe bad Input should produce null');
        System.assertEquals(null, fflib_SObjectDescribe.getDescribe(nullDescribe), 'get Describe bad Input should produce null');
        System.assertEquals(null, fflib_SObjectDescribe.getDescribe(nullSObject), 'get Describe bad Input should produce null');
    }

    @IsTest
    static void NamespacedAttributeMap_implementations()
    {
        fflib_SObjectDescribe.GlobalDescribeMap gdm = fflib_SObjectDescribe.getGlobalDescribe();
        Schema.SObjectType accountObjType = gdm.get('AccOunT');
        System.assertEquals(accountObjType, Account.SobjectType, 'Namespaced Attribute Map implementations should produce accountObjType');
        System.assertEquals(Schema.getGlobalDescribe().size(), gdm.size(), 'Namespaced Attribute Map implementations should produce Schema.getGlobalDescribe().size()');

        fflib_SObjectDescribe acccountDescribe = fflib_SObjectDescribe.getDescribe(accountObjType);
        fflib_SObjectDescribe.FieldsMap fields = acccountDescribe.getFields();
        System.assert( fields.keySet().containsAll(acccountDescribe.getFieldsMap().keySet()) , 'Namespaced Attribute Map implementations should satisfy fields.keySet().containsAll(acccountDescribe.getFieldsMap().keySet())');

        System.assertEquals(fields.get('name'), Account.SObjectType.fields.name, 'Namespaced Attribute Map implementations should produce fields.get(name)'); //behavior of FieldsMap is tested in another method
        System.assertEquals(Schema.SObjectType.Account.fields.getMap().size(), fields.size(), 'Namespaced Attribute Map implementations should produce Schema.SObjectType.Account.fields.getMap().size()');

        System.assertEquals(null, fields.get(null), 'Null input should result in null ouput.');
        System.assertEquals(null, fields.get(''), 'Invalid fieldname input should result in null ouput.');
    }

    @IsTest
    static void FieldsMap()
    {
        String fakeNamespace = 'fflib_test';
        Map<String,Schema.SObjectField> fakeFieldData = new Map<String,Schema.SObjectField>{
            'name__c' => Contact.SObjectType.fields.name, //re-use standard field types since we can't mock them
            fakeNamespace+'__name__c' => Account.SObjectType.fields.name,
            fakeNamespace+'__otherField__c' => Account.SObjectType.fields.name,
            'createddate' => Contact.SObjectType.fields.CreatedDate
        }
;
        fflib_SObjectDescribe.FieldsMap fields = new fflib_SObjectDescribe.FieldsMap(fakeFieldData);
        fields.currentNamespace = fakeNamespace;
        System.assertEquals(true, fields.containsKey('name__c') , 'Fields Map should produce true');
        System.assertEquals(true, fields.containsKey(fakeNamespace.toUpperCase()+'__nAMe__c') , 'Fields Map should produce true');
        System.assert(fields.get('NAme__c') === fields.get(fakeNamespace+'__namE__c'), 'Fields Map should satisfy fields.get(NAme__c) === fields.get(fakeNamespace+__namE__c)');

        System.assert(!fields.keySet(false).contains('otherField__c'), 'Fields Map should satisfy !fields.keySet(false).contains(otherField__c)');
        System.assert(fields.keySet(false).contains(fakeNamespace+'__otherField__c'), 'Fields Map should satisfy fields.keySet(false).contains(fakeNamespace+__otherField__c)');

        System.assert(fields.keySet(true).contains('otherField__c'), 'Fields Map should satisfy fields.keySet(true).contains(otherField__c)');
        System.assert(!fields.keySet(true).contains(fakeNamespace+'__otherField__c'), 'Fields Map should satisfy !fields.keySet(true).contains(fakeNamespace+__otherField__c)');

        fields.currentNamespace = 'someOtherNamespace';
        System.assertNotEquals(fields.get('name__C'), fields.get(fakeNamespace.capitalize()+'__nAme__c'), 'Fields Map should not produce fields.get(name__C)');
    }

    @IsTest
    static void GlobalDescribeMap()
    {
        String fakeNamespace = 'fflib_test';
        Map<String,Schema.SObjectType> fakeFieldData = new Map<String,Schema.SObjectType>{
            'name__c' => Contact.SObjectType, //re-use stndard object types since we can't mock them
            fakeNamespace+'__name__c' => Account.SObjectType,
            'createddate' => Lead.SObjectType
        }
;
        fflib_SObjectDescribe.GlobalDescribeMap gdm = new fflib_SObjectDescribe.GlobalDescribeMap(fakeFieldData);
        gdm.currentNamespace = fakeNamespace;
        System.assertEquals(true, gdm.containsKey('name__c') , 'Global Describe Map should produce true');
        System.assertEquals(true, gdm.containsKey(fakeNamespace+'__name__c') , 'Global Describe Map should produce true');
        System.assert(gdm.get('name__c') === gdm.get(fakeNamespace+'__name__c'), 'Global Describe Map should satisfy gdm.get(name__c) === gdm.get(fakeNamespace+__name__c)');

        gdm.currentNamespace = 'someOtherNamespace';
        System.assertNotEquals(gdm.get('name__c'), gdm.get(fakeNamespace+'__name__c'), 'Global Describe Map should not produce gdm.get(name__c)');
    }

    @IsTest //Tests all forms of the getDescribe static
    static void getAccountDescribes()
    {
        fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe('Account');
        fflib_SObjectDescribe d2 = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
        fflib_SObjectDescribe d3 = fflib_SObjectDescribe.getDescribe(Schema.SObjectType.Account);
        System.assertEquals('Account', d.getDescribe().getName(), 'get Account Describes should produce Account');
        System.assert( (d === d2 && d2 === d3) ,'All three getDescribe calls should return the same cached instance.');
    }

    @IsTest
    static void simpleAccountFieldDescribe()
    {
        fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
        Map<String,Schema.SObjectField> fields;
        for(integer i = 0; i < 10; i++)
        {
            fields = d.getFieldsMap();
        }

        // Describe Limits removed since Summer ’14.
        // https://developer.salesforce.com/releases/release/Summer14/New+Apex+Enhancements

        // Because describe limits are no longer enforced in any API version, this method is no longer available.
        // In API version 30.0 and earlier, this method is available but is deprecated.

        // System.assertEquals(1, Limits.getFieldsDescribes() );

        System.assertEquals(false,fields.isEmpty(), 'simple Account Field Describe should produce false');
        System.assertEquals(Account.SObjectType, d.getSObjectType(), 'simple Account Field Describe should produce Account.SObjectType');
    }

    @IsTest
    static void simpleAccountFieldSetDescribe()
    {
        fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
        Map<String,Schema.FieldSet> fields;
        for(integer i = 0; i < 10; i++)
        {
            fields = d.getFieldSetsMap();
        }

        // Describe Limits removed since Summer ’14.
        // https://developer.salesforce.com/releases/release/Summer14/New+Apex+Enhancements

        // Because describe limits are no longer enforced in any API version, this method is no longer available.
        // In API version 30.0 and earlier, this method is available but is deprecated.

        // System.assertEquals(1, Limits.getFieldSetsDescribes() );

        System.assertNotEquals(null, fields, 'Field set describe map should be initialized even when no field sets exist.');
    }

    @IsTest
    static void simpleAccountGetNameField()
    {
        fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
        Schema.SObjectField nameField = d.getNameField();
        System.assertEquals('Name', nameField.getDescribe().getName(), 'simple Account Get Name Field should produce Name');
    }

    @IsTest
    static void flushCache()
    {
        fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe('Account');
        fflib_SObjectDescribe.flushCache();
        fflib_SObjectDescribe d2 = fflib_SObjectDescribe.getDescribe('Account');
        System.assert(d !== d2, 'Second object should be a fresh instance after a cache flush.' );
    }

    @IsTest
    static void rawGlobalDescribeCheck()
    {
        Map<String,Schema.SObjectType> systemGd = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectType> cachedGd = fflib_SObjectDescribe.getRawGlobalDescribe();
        System.assertEquals(systemGd.size(),cachedGd.size(), 'raw Global Describe Check should produce systemGd.size()');
    }

}
