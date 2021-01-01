/**************************************************************************
 * @author           srnandan
 * @date             23/November/2018
 * @group            AirBP
 * @description      Test class for AITM_LABPForgotPasswordController

 * history
 * 23/November/2018      srnandan       Created
 *******************************************************************/
@IsTest(SeeAllData = true)
public with sharing class AITM_LABPForgotPasswordControllerTests {
    /**
     * @description Verifies that ForgotPasswordController handles invalid usernames appropriately
     * @param  null
     * @return void
     */
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        System.assertEquals(AITM_LABPForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.LABP_Invalid_Username);
        System.assertEquals(AITM_LABPForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.LABP_Invalid_Username);
        System.assertEquals(AITM_LABPForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.LABP_Invalid_Username);
    }
    /**
     * @description Verifies that null checkEmailRef url throws proper exception.
     * @param  null
     * @return void
     */
    @IsTest
    static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
        System.assertEquals(AITM_LABPForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
        System.assertEquals(AITM_LABPForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
    }
    
    /**
     * @description Verifies that LightningForgotPasswordController object is instantiated correctly.
     * @param  null
     * @return void
     */
    @IsTest
    static void LightningForgotPasswordControllerInstantiation() {
        AITM_LABPForgotPasswordController controller = new AITM_LABPForgotPasswordController();
        System.assertNotEquals(controller, null);
    }
}