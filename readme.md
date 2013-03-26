# What is this?

notify users about new features(change log) in the app the first time they launch after an update.

simple!

# How to Use

1. D&D [NotifyChangeLog](https://github.com/azu/notify-changeLog/tree/master/notify-changeLog/NotifyChangeLog "NotifyChangeLog") directory into your project.
2. Write change log to ``ChangeLog.plist``
3. Call ``[NotifyChangeLog showAndSave];`` - show change log in UIAlertView

also get change log - call ``[NotifyChangeLog changeLogAtCurrent];``
(with have to manually save - ``[NotifyChangeLog saveCurrentVersion]`` )

Add code for insurance :

    - (void)applicationDidEnterBackground:(UIApplication *)application
    {
        [NotifyChangeLog saveCurrentVersion];
    }

# Example

[azu/NotifyChangeLogExample · GitHub](https://github.com/azu/NotifyChangeLogExample "azu/NotifyChangeLogExample · GitHub")

## similarity

* [nicklockwood/iVersion](https://github.com/nicklockwood/iVersion "nicklockwood/iVersion")