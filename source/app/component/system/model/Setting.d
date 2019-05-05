module app.component.system.model.Setting;

import hunt.entity;

@Table("system_setting")
class Setting : Model
{
    mixin MakeModel;

    // @OneToMany("role")
    // UserRole[] userRoles;
    @PrimaryKey
    string key;

    // 1: enabled, 0: disabled
    string value;

}

struct SettingItem
{
    string key;
}

class SettingObject
{
    @SettingItem("site_name")
    string siteName = "葡萄科技";

    @SettingItem("site_url")
    string siteUrl = "https://localhost/";

    @SettingItem("site_keyworkds")
    string siteKeywords = "葡萄科技";

    @SettingItem("site_description")
    string siteDescription = "A huntcms based website.";

    @SettingItem("site_author")
    string siteAuthor = "葡萄科技";
    // @SettingItem("site_status")
    // bool siteStatus = true;
}
