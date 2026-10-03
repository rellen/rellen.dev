-- Dhall schema for a single talk
{ Type =
    { title : Text
    , description : Text
    , organisation : Text
    , year : Natural
    , month : Natural
    , video : Optional Text
    , slides : Optional Text
    }
, default = { video = None Text, slides = None Text }
}
