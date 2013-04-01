<?php
/**
 * Sitewide configuration.
 * 
 * h2. Translation
 * 
 * To enable translation of configurations alongside the {@link Translatable} extension.
 * This also allows assigning language-specific toplevel permissions for viewing and editing
 * pages, in addition to the normal `TRANSLATE_*`/`TRANSLATE_ALL` permissions.
 * 
 * 	Object::add_extension('SiteConfig', 'Translatable');
 *
 * @author Tom Rix
 * @package cms
 */
class SiteConfig extends DataObject implements PermissionProvider {
	static $db = array(
		"Title" => "Varchar(255)",
		"Tagline" => "Varchar(255)",
		"Theme" => "Varchar(255)",
		"CanViewType" => "Enum('Anyone, LoggedInUsers, OnlyTheseUsers', 'Anyone')",
		"CanEditType" => "Enum('LoggedInUsers, OnlyTheseUsers', 'LoggedInUsers')",
		"CanCreateTopLevelType" => "Enum('LoggedInUsers, OnlyTheseUsers', 'LoggedInUsers')",
		"Company" => "Text",
		"Address1" => "Text",
		"Address2" => "Text",
		"Address3" => "Text",
		"PostCode" => "Text",
		"Telephone" => "Text",
		"Fax" => "Text",
		"Email" => "Text",
		"DefaultReportOpeningText" => "HTMLText",
		"DefaultReportClosingText" => "HTMLText",
		"DefaultProjectHelpText" => "HTMLText"
	);
	
	static $has_one = array(
		"FeaturedTestimonial" => "Testimonial",
		"Small_Image1" => "Image",
		"Small_Image2" => "Image",
		"Small_Image3" => "Image",
		"Small_Image4" => "Image"
	);
	
	public static $has_many = array(
		"HeaderImages" => "HeaderImage"
	);
	
	static $many_many = array(
		"ViewerGroups" => "Group",
		"EditorGroups" => "Group",
		"CreateTopLevelGroups" => "Group"
	);
	
	protected static $disabled_themes = array();
	
	public static function disable_theme($theme) {
		self::$disabled_themes[$theme] = $theme;
	}
	
	/**
	 * Get the fields that are sent to the CMS. In
	 * your decorators: updateCMSFields(&$fields)
	 *
	 * @return Fieldset
	 */
	function getCMSFields() {
		Requirements::javascript(CMS_DIR . "/javascript/SitetreeAccess.js");

		$fields = new FieldSet(
			new TabSet("Root",
				$tabMain = new Tab('Main',
					$titleField = new TextField("Title", _t('SiteConfig.SITETITLE', "Site title")),
					$taglineField = new TextField("Tagline", _t('SiteConfig.SITETAGLINE', "Site Tagline/Slogan")),
					new DropdownField("Theme", _t('SiteConfig.THEME', 'Theme'), $this->getAvailableThemes(), '', null, _t('SiteConfig.DEFAULTTHEME', '(Use default theme)'))
				),
				$tabAccess = new Tab('Access',
					new HeaderField('WhoCanViewHeader', _t('SiteConfig.VIEWHEADER', "Who can view pages on this site?"), 2),
					$viewersOptionsField = new OptionsetField("CanViewType"),
					$viewerGroupsField = new TreeMultiselectField("ViewerGroups", _t('SiteTree.VIEWERGROUPS', "Viewer Groups")),
					new HeaderField('WhoCanEditHeader', _t('SiteConfig.EDITHEADER', "Who can edit pages on this site?"), 2),
					$editorsOptionsField = new OptionsetField("CanEditType"),
					$editorGroupsField = new TreeMultiselectField("EditorGroups", _t('SiteTree.EDITORGROUPS', "Editor Groups")),
					new HeaderField('WhoCanCreateTopLevelHeader', _t('SiteConfig.TOPLEVELCREATE', "Who can create pages in the root of the site?"), 2),
					$topLevelCreatorsOptionsField = new OptionsetField("CanCreateTopLevelType"),
					$topLevelCreatorsGroupsField = new TreeMultiselectField("CreateTopLevelGroups", _t('SiteTree.TOPLEVELCREATORGROUPS', "Top level creators"))
				)
			)
		);
		
		/*$tp = DataObject::get_one("TestimonialHolder");
		$testimonials = DataObject::get("Testimonial", "TestimonialHolderID = {$tp->ID}");
		if ($testimonials) {
			$testimonials = $testimonials->toDropdownMap("ID", "Client");
			$fields->addFieldToTab("Root.FeaturedTestimonial", new DropdownField("FeaturedTestimonialID", "Testimonial Featured on bottom right of each page", $testimonials));
		} else {
			$fields->addFieldToTab("Root.FeaturedTestimonial", new LabelField("FeaturedTestimonial", "Once you add testimonials to the site, you will be able to choose which one appears at the bottom of each page"));
		}
		
		$fields->addFieldToTab("Root.CyclingHeaderImages", new LiteralField("HI", "<p>For best results, images need to be 442px x 176px, if not, they will be stretched / skewed to this size.</p>"));
		$fields->addFieldToTab("Root.CyclingHeaderImages", new ImageDataObjectManager (
			$this,
			"HeaderImages",
			"HeaderImage",
			"Image",
			"",
			"getCMSFields_forPopup"
		));
		
		$fields->addFieldToTab("Root.SmallHeaderImages", new ImageField("Small_Image1", "Small image 1: (67px x 68px)"));
		$fields->addFieldToTab("Root.SmallHeaderImages", new ImageField("Small_Image2", "Small image 2: (67px x 68px)"));
		$fields->addFieldToTab("Root.SmallHeaderImages", new ImageField("Small_Image3", "Small image 3: (67px x 68px)"));
		$fields->addFieldToTab("Root.SmallHeaderImages", new ImageField("Small_Image4", "Small image 4: (67px x 68px)"));
				
		$fields->addFieldToTab("Root.ContactInfo", new TextField("Company", "Company Name:"));
		$fields->addFieldToTab("Root.ContactInfo", new TextField("Address1", "Address Line 1:"));
		$fields->addFieldToTab("Root.ContactInfo", new TextField("Address2", "Address Line 2:"));
		$fields->addFieldToTab("Root.ContactInfo", new TextField("Address3", "Address Line 3:"));
		$fields->addFieldToTab("Root.ContactInfo", new TextField("PostCode", "Postcode:"));
		$fields->addFieldToTab("Root.ContactInfo", new TextField("Telephone", "Telephone No:"));
		$fields->addFieldToTab("Root.ContactInfo", new TextField("Fax", "Fax No:"));
		$fields->addFieldToTab("Root.ContactInfo", new TextField("Email", "Email Address:"));
		
		$viewersOptionsSource = array();
		$viewersOptionsSource["Anyone"] = _t('SiteTree.ACCESSANYONE', "Anyone");
		$viewersOptionsSource["LoggedInUsers"] = _t('SiteTree.ACCESSLOGGEDIN', "Logged-in users");
		$viewersOptionsSource["OnlyTheseUsers"] = _t('SiteTree.ACCESSONLYTHESE', "Only these people (choose from list)");
		$viewersOptionsField->setSource($viewersOptionsSource);
		
		$editorsOptionsSource = array();
		$editorsOptionsSource["LoggedInUsers"] = _t('SiteTree.EDITANYONE', "Anyone who can log-in to the CMS");
		$editorsOptionsSource["OnlyTheseUsers"] = _t('SiteTree.EDITONLYTHESE', "Only these people (choose from list)");
		$editorsOptionsField->setSource($editorsOptionsSource);
		
		$topLevelCreatorsOptionsField->setSource($editorsOptionsSource);
		*/
		// Translatable doesn't handle updateCMSFields on DataObjects,  
		// so add it here to save the current Locale,  
		// because onBeforeWrite does not work. 
		if(Object::has_extension('SiteConfig',"Translatable")){ 
			$fields->push(new HiddenField("Locale"));  
		}

		if (!Permission::check('EDIT_SITECONFIG')) {
			$fields->makeFieldReadonly($viewersOptionsField);
			$fields->makeFieldReadonly($viewerGroupsField);
			$fields->makeFieldReadonly($editorsOptionsField);
			$fields->makeFieldReadonly($editorGroupsField);
			$fields->makeFieldReadonly($topLevelCreatorsOptionsField);
			$fields->makeFieldReadonly($topLevelCreatorsGroupsField);
			$fields->makeFieldReadonly($taglineField);
			$fields->makeFieldReadonly($titleField);
		}
		$tabMain->setTitle(_t('SiteConfig.TABMAIN', "Main"));
		$tabAccess->setTitle(_t('SiteConfig.TABACCESS', "Access"));
		$this->extend('updateCMSFields', $fields);
		
		return $fields;
	}

	/**
	 * Get all available themes that haven't been marked as disabled.
	 * @param string $baseDir Optional alternative theme base directory for testing
	 * @return array of theme directory names
	 */
	public function getAvailableThemes($baseDir = null) {
		$themes = ManifestBuilder::get_themes($baseDir);
		foreach(self::$disabled_themes as $theme) {
			if(isset($themes[$theme])) unset($themes[$theme]);
		}
		return $themes;
	}
	
	/**
	 * Get the actions that are sent to the CMS. In
	 * your decorators: updateEditFormActions(&$actions)
	 *
	 * @return Fieldset
	 */
	function getCMSActions() {
		if (Permission::check('ADMIN') || Permission::check('EDIT_SITECONFIG')) {
			$actions = new FieldSet(
				new FormAction('save_siteconfig', _t('CMSMain.SAVE','Save'))
			);
		} else {
			$actions = new FieldSet();
		}
		
		$this->extend('updateCMSActions', $actions);
		
		return $actions;
	}
	
	/**
	 * Get the current sites SiteConfig, and creates a new one
	 * through {@link make_site_config()} if none is found.
	 *
	 * @param string $locale
	 * @return SiteConfig
	 */
	static function current_site_config($locale = null) {
		if(Object::has_extension('SiteConfig',"Translatable")){
			$locale = isset($locale) ? $locale : Translatable::get_current_locale();
			$siteConfig = Translatable::get_one_by_locale('SiteConfig', $locale);
		} else {
			$siteConfig = DataObject::get_one('SiteConfig');
		}
		
		if (!$siteConfig) $siteConfig = self::make_site_config($locale);
		
		return $siteConfig;
	}
	
	/**
	 * Setup a default SiteConfig record if none exists
	 */
	function requireDefaultRecords() {
		parent::requireDefaultRecords();
		$siteConfig = DataObject::get_one('SiteConfig');
		if(!$siteConfig) {
			self::make_site_config();
			DB::alteration_message("Added default site config","created");
		}
	}
	
	/**
	 * Create SiteConfig with defaults from language file.
	 * if Translatable is enabled on SiteConfig, see if one already exist
	 * and use those values for the translated defaults. 
	 * 
	 * @param string $locale
	 * @return SiteConfig
	 */
	static function make_site_config($locale = null) {
		if(!$locale) $locale = Translatable::get_current_locale();
		
		$siteConfig = new SiteConfig();
		$siteConfig->Title = _t('SiteConfig.SITENAMEDEFAULT',"Your Site Name");
		$siteConfig->Tagline = _t('SiteConfig.TAGLINEDEFAULT',"your tagline here");

		if($siteConfig->hasExtension('Translatable')){
			$defaultConfig = DataObject::get_one('SiteConfig');
			if($defaultConfig){
				$siteConfig->Title = $defaultConfig->Title;
				$siteConfig->Tagline = $defaultConfig->Tagline;
			}
			
			// TODO Copy view/edit group settings
			
			// set the correct Locale
			$siteConfig->Locale = $locale;
		}

		$siteConfig->write();
		
		return $siteConfig;
 	}
	
	/**
	 * Can a user view pages on this site? This method is only
	 * called if a page is set to Inherit, but there is nothing
	 * to inherit from.
	 *
	 * @param mixed $member 
	 * @return boolean
	 */
	public function canView($member = null) {
		if(!$member) $member = Member::currentUserID();
		if($member && is_numeric($member)) $member = DataObject::get_by_id('Member', $member);

		if (!$this->CanViewType || $this->CanViewType == 'Anyone') return true;
				
		// check for any logged-in users
		if($this->CanViewType == 'LoggedInUsers' && $member) return true;

		// check for specific groups
		if($this->CanViewType == 'OnlyTheseUsers' && $member && $member->inGroups($this->ViewerGroups())) return true;
		
		return false;
	}
	
	/**
	 * Can a user edit pages on this site? This method is only
	 * called if a page is set to Inherit, but there is nothing
	 * to inherit from.
	 *
	 * @param mixed $member 
	 * @return boolean
	 */
	public function canEdit($member = null) {
		if(!$member) $member = Member::currentUserID();
		if($member && is_numeric($member)) $member = DataObject::get_by_id('Member', $member);

		// check for any logged-in users
		if(!$this->CanEditType || $this->CanEditType == 'LoggedInUsers' && $member) return true;

		// check for specific groups
		if($this->CanEditType == 'OnlyTheseUsers' && $member && $member->inGroups($this->EditorGroups())) return true;
		
		return false;
	}
	
	function providePermissions() {
		return array(
			'EDIT_SITECONFIG' => array(
				'name' => _t('SiteConfig.EDIT_PERMISSION', 'Manage site configuration'),
				'category' => _t('Permissions.PERMISSIONS_CATEGORY', 'Roles and access permissions'),
				'help' => _t('SiteConfig.EDIT_PERMISSION_HELP', 'Ability to edit global access settings/top-level page permissions.'),
				'sort' => 400
			)
		);
	}
	
	/**
	 * Can a user create pages in the root of this site?
	 *
	 * @param mixed $member 
	 * @return boolean
	 */
	public function canCreateTopLevel($member = null) {
		if(!$member || !(is_a($member, 'Member')) || is_numeric($member)) {
			$member = Member::currentUserID();
		}
		
		if (Permission::check('ADMIN')) return true;

		// check for any logged-in users
		if($this->CanCreateTopLevelType == 'LoggedInUsers' && $member) return true;
		
		// check for specific groups
		if($member && is_numeric($member)) $member = DataObject::get_by_id('Member', $member);
		if($this->CanCreateTopLevelType == 'OnlyTheseUsers' && $member && $member->inGroups($this->CreateTopLevelGroups())) return true;
		

		return false;
	}
}
