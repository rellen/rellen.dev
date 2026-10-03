--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Data.Monoid (mappend)
import Hakyll

--------------------------------------------------------------------------------

siteConfig :: Configuration
siteConfig = defaultConfiguration {providerDirectory = "site"}

main :: IO ()
main = do
  hakyllWith siteConfig $ do
    match "images/*" $ do
      route $ gsubRoute "assets/" (const "")
      compile copyFileCompiler

    match "assets/css/*.css" $ do
      route $ gsubRoute "assets/" (const "")
      compile compressCssCompiler

    match "assets/fonts/*" $ do
      route $ gsubRoute "assets/" (const "")
      compile copyFileCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
      route $ setExtension "html"
      compile $
        pandocCompiler
          >>= loadAndApplyTemplate "templates/default.html" defaultContext
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
                `mappend` defaultContext

        makeItem ""
          >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
          >>= loadAndApplyTemplate "templates/default.html" archiveCtx
          >>= relativizeUrls

    match "index.html" $ do
      route $ gsubRoute "content/" (const "")
      compile $ do
        posts <- recentFirst =<< loadAll "content/posts/*"
        let indexCtx =
              listField "posts" postCtx (return posts)
                `mappend` defaultContext

        getResourceBody
          >>= applyAsTemplate indexCtx
          >>= loadAndApplyTemplate "templates/default.html" indexCtx
          >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
  dateField "date" "%B %e, %Y"
    `mappend` defaultContext
