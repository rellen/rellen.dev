{-# LANGUAGE DeriveGeneric #-}
--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

module Site.Talks (loadTalks, talksContext) where

import Data.Maybe
import qualified Data.Text as T
import qualified Dhall
import GHC.Generics
import Hakyll
import Numeric.Natural (Natural)
import Text.Pandoc (def, readMarkdown, runPure, writeHtml5String)

data Talk = Talk
  { title :: T.Text,
    description :: T.Text, -- Markdown content
    organisation :: T.Text,
    year :: Natural,
    month :: Natural,
    video :: Maybe T.Text,
    slides :: Maybe T.Text
  }
  deriving (Generic, Show)

instance Dhall.FromDhall Talk

markdownToHtml :: T.Text -> String
markdownToHtml markdown =
  case runPure (readMarkdown def markdown >>= writeHtml5String def) of
    Left _ -> T.unpack markdown
    Right html -> T.unpack html

loadTalks :: FilePath -> IO [Talk]
loadTalks filepath = Dhall.inputFile (Dhall.list Dhall.auto) filepath

-- Format date for display
formatDate :: Natural -> Natural -> String
formatDate year month = monthName month ++ " " ++ show year
  where
    monthName 1 = "January"
    monthName 2 = "February"
    monthName 3 = "March"
    monthName 4 = "April"
    monthName 5 = "May"
    monthName 6 = "June"
    monthName 7 = "July"
    monthName 8 = "August"
    monthName 9 = "September"
    monthName 10 = "October"
    monthName 11 = "November"
    monthName 12 = "December"
    monthName _ = "Unknown"

talksContext :: [Talk] -> Context String
talksContext talks = listField "talks" talkItemContext (mapM makeItem talks)

talkItemContext :: Context Talk
talkItemContext =
  mconcat
    [ talkTitleField,
      talkDescriptionField,
      talkOrganisationField,
      talkYearField,
      talkMonthField,
      talkDateField,
      talkVideoField,
      talkSlidesField,
      talkHasVideoField,
      talkHasSlidesField
    ]

talkTitleField = field "title" (return . T.unpack . title . itemBody)

talkDescriptionField = field "description" (return . markdownToHtml . description . itemBody)

talkOrganisationField = field "organisation" (return . T.unpack . organisation . itemBody)

talkYearField = field "year" (return . show . year . itemBody)

talkMonthField = field "month" (return . show . month . itemBody)

talkDateField = field "date" (\item -> return $ formatDate (year $ itemBody item) (month $ itemBody item))

talkVideoField = field "videoUrl" (return . T.unpack . fromMaybe T.empty . video . itemBody)

talkSlidesField = field "slidesUrl" (return . T.unpack . fromMaybe T.empty . slides . itemBody)

talkHasVideoField = field "hasVideo" (\item -> return $ if T.null (fromMaybe T.empty $ video $ itemBody item) then "false" else "true")

talkHasSlidesField = field "hasSlides" (\item -> return $ if T.null (fromMaybe T.empty $ slides $ itemBody item) then "false" else "true")
