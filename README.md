Assumptions :
        Finacial services cloud is installed in the org which achieves the required data model.
        To create an SF developer account with  FSC you can access the below link 
        https://developer.salesforce.com/promotions/orgs/fscplayground

        For simplicity , 
        It is assumed that all branch staff members will have the profile 'Advisor'.
        all staff members will be assigned 'Advisor Permissions' custom permission set.
        All middle ware systems that will consume the create transaction service will have system admin access.

        Wealth Management App will be the go to app for the staff.
Issues :
        Currently we are unable to extract the FSC managed package layouts hence some of the fileds are not vissible this will have to be added manualy.
        1) fields Account Number and Customer Number on financial account.
      