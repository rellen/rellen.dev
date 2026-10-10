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
import Text.Printf (printf)

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
      talkYearMonthField,
      talkFormattedDateField,
      talkVideoField,
      talkSlidesField
    ]

talkTitleField = field "title" (return . T.unpack . title . itemBody)

talkDescriptionField = field "description" (return . markdownToHtml . description . itemBody)

talkOrganisationField = field "organisation" (return . T.unpack . organisation . itemBody)

talkYearField = field "year" (return . show . year . itemBody)

talkMonthField = field "month" (return . show . month . itemBody)

talkYearMonthField = field "isoDate" $ \item ->
  let t = itemBody item
   in return (printf "%d-%02d" (year t) (month t))

talkFormattedDateField = field "formattedDate" $ \item ->
  let t = itemBody item
   in return $ formatDate (year t) (month t)

talkVideoField = field "videoUrl" (optionalField . video . itemBody)

talkSlidesField = field "slidesUrl" (optionalField . slides . itemBody)

optionalField :: Maybe T.Text -> Compiler String
optionalField = maybe (noResult "not set") (return . T.unpack)
