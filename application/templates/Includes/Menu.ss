var mainMenu = new Ext.Toolbar({
	items : [
	'->',
	'Logged in as $CurrentMember.FirstName $CurrentMember.Surname',
	'-',
	{
		text: 'Logout',
		icon: 'application/images/login/logout.png',
		handler: function() {
			Ext.MessageBox.confirm('Confirm', 'Are you sure you want to logout?', function(button){
				if (button == 'yes') {
					loadingMask.show();
					location.href = 'Security/logout';
				}
			});
		}
	}]
});

/*
{
		text: 'Home',
		icon: 'application/images/built_in_menus/home.png',
		menu: HomeMenu
	},
	topMenuNavigation
	< if adminPermissionCheck >
	{
		text: 'Administration',
		icon: 'application/images/built_in_menus/administration.png',
		menu: AdministrationMenu
	},
	< end_if >
	
*/
