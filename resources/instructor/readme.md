# Instructor Support Files

This folder contains various files to support classroom configurations, intended for instructor/proctor use. 

Please use caution when running scripts/templates as some may deploy large assets.

## ARM Templates

The various ARM templates in the folder support typical classroom configuration so a single Event Hub may be deployed and each attendee can connect using an designated consumer group, one for each attendee. Some templates are designed to be further customized to meet classroom specific needs. 

Consumer groups can be created manually, 

| File | Notes |
|--:|---|
| fabricworkshop_arm_class_setup | Premium Event Hub with up to 100 consumer groups ($Default, 1-99) |
| fabricworkshop_arm_class_setup_deckofcards | Premium Event Hub; consumer groups named after a deck of cards ($Default, 52 groups)  |
| fabricworkshop_arm_class_setup_2_deckofcards | Premium Event Hub; consumer groups named after two decks of cards ($Default, 100  groups)  |
| fabricworkshop_arm_class_setup_stockteam | Premium Event Hub; consumer groups named after various teams |
| fabricworkshop_arm_class_setup_names | Premium Event Hub; consumer groups named after input array (such as first name/last initial) |