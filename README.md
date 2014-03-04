PoloApp
=======

A navigational assistant by Matt Brenman and Julian Locke for TuftsHack Spring 2014

Polo TODO
=========

Needed before pushing to App Store:
* DONE-Limit API requests from Parse per connection — download target’s data less frequently and animate, it shouldn’t change terribly often (maybe every 5 seconds?)
* DONE-Connect to any user in friend list
* DONE-Only can add friend if the friend exists in DB
* Users have a whitelist of current callers
* Connections should only happen if on whitelist
* DONE-Fix add friend issue when the user has no friends
* DONE-Make user zero-out location data on closing out of arrow view
* DONE-Fix crash on logout after seeing the arrow
* Maybe something with calibration?
* Make usernames NOT case sensitive (importance?)
* DONE-Remove testflight
* delete friends
* integrate iAd
* Add custom nav bar
* DONE Organize friends in list - alphabetize?
* encrypt all location data between users - public/private keys for users? Can Parse do this?

New features:

* Arbitrary points as friends — make a new type without API? Friend/Points as tab view controller?
* Whitelist of users that can always connect - how do we update from the non-user’s phone?
* Show “waiting…” or “connecting…” before pulling target’s data or when target is at (0º, 0º) —> not connecting
* Add call or text button from the arrow screen (blank out if no supplied phone number)
* Update friend list with contact nicknames/names if phone number is supplied and in contacts
* Make adding friends faster
* Custom colors -- change icon too
* Custom Skin for login, less parse-y
