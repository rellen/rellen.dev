--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import Data.Monoid (mappend)
import Hakyll
import Site.Talks

--------------------------------------------------------------------------------

siteConfig :: Configuration
siteConfig = defaultConfiguration {providerDirectory = "site"}

siteCtx :: Context String
siteCtx = constField "siteRoot" "https://rellen.dev" `mappend` defaultContext

postCtx :: Context String
postCtx =
  dateField "date" "%B %e, %Y"
    `mappend` siteCtx

applyTemplateChain [] item = return item
applyTemplateChain ((templateId, ctx) : rest) item = do
  result <- loadAndApplyTemplate templateId ctx item
  applyTemplateChain rest result

assetsRoute = route $ gsubRoute "assets/" (const "")

main :: IO ()
main = do
  hakyllWith siteConfig $ do
    match "assets/images/*" $ do
      assetsRoute
      compile copyFileCompiler

    match "assets/css/*.css" $ do
      assetsRoute
      compile compressCssCompiler

    match "assets/fonts/*" $ do
      assetsRoute
      compile copyFileCompiler

    -- Generate talks page from Dhall data
    create ["talks.html"] $ do
      route idRoute
      compile $ do
        talks <- unsafeCompiler $ loadTalks "site/data/talks.dhall"
        let talksPageCtx =
              talksContext talks
                `mappend` constField "title" "Talks"
                `mappend` siteCtx

        makeItem ""
          >>= applyTemplateChain [("templates/talks.html", talksPageCtx), ("templates/default.html", talksPageCtx)]
          >>= relativizeUrls

    match (fromList ["content/about.org"]) $ do
      route $ gsubRoute "content/" (const "") `composeRoutes` setExtension "html"
      compile $
        pandocCompiler
          >>= loadAndApplyTemplate "templates/default.html" siteCtx
          >>= relativizeUrls

    match "posts/*" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler
          >>= loadAndApplyTemplate "templates/post.html" postCtx
          >>= loadAndApplyTemplate "templates/default.html" postCtx
          >>= relativizeUrls

    create ["archive.html"] $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*"
        let archiveCtx =
              listField "posts" postCtx (return posts)
                `mappend` constField "title" "Archives"
                `mappend` siteCtx

        makeItem ""
          >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
          >>= loadAndApplyTemplate "templates/default.html" archiveCtx
          >>= relativizeUrls

    match "content/index.html" $ do
      route $ gsubRoute "content/" (const "")
      compile $ do
        posts <- recentFirst =<< loadAll "content/posts/*"
        let indexCtx =
              listField "posts" postCtx (return posts)
                `mappend` siteCtx

        getResourceBody
          >>= applyAsTemplate indexCtx
          >>= loadAndApplyTemplate "templates/default.html" indexCtx
          >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
