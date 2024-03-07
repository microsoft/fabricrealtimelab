# Instructor Support Files

This folder contains various files to support classroom configurations, intended for instructor/proctor use. 

Please use caution when running scripts/templates as some may deploy large assets.

## ARM Templates

The various ARM templates in the folder support typical classroom configuration so a single EventHub may be deployed and each attendee can connect using an designated consumer group, one for each attendee. Some templates are designed to be further customized to meet classroom specific needs.

| File | Notes |
|--:|---|
| fabricworkshop_arm_class_setup | Premium EventHub with up to 100 consumer groups ($Default, 1-99) |
| fabricworkshop_arm_class_setup_deckofcards | Premium EventHub; consumer groups named after a deck of cards ($Default, 52 groups)  |
| fabricworkshop_arm_class_setup_stockteam | Premium EventHub; consumer groups named after various teams ($Default, 52 groups) |