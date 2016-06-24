#!/usr/bin/env runhaskell

-- 1. create _build
-- 2. move all items into _build

import Development.Shake
import Development.Shake.FilePath


toBuild,fromBuild :: FilePath -> FilePath
toBuild   src = "_build" </> src
fromBuild out = joinPath (filter (/="_build/") (splitPath out))

resultFileList :: [FilePattern]
resultFileList = ["main.pdf"]

paperFileList :: [FilePattern]
paperFileList =
  [ "main.tex"
  , "llncs.cls"
  , "preamble.tex"
  , "main.bib"
  , "fig-*.tex"
  ]

main :: IO ()
main =
  shakeArgs shakeOptions { shakeFiles = "_build" } $ do

    want [ "main.pdf" ]

    -- compile main.tex with PdfLaTeX
    toBuild "main.pdf" %> \out -> do
      let
        src  = out -<.> "tex"
        lcl  = fromBuild src

      paperFiles <- getDirectoryFiles "" paperFileList
      need (toBuild <$> paperFiles)

      command_ [Cwd "_build", EchoStdout True] "pdflatex" ["-draftmode", lcl]
      command_ [Cwd "_build", WithStdout True] "bibtex"   [dropExtension lcl]
      command_ [Cwd "_build", WithStdout True] "pdflatex" ["-draftmode", lcl]
      command_ [Cwd "_build", WithStdout True] "pdflatex" [lcl]

    -- copy files into the _build directory
    toBuild <$> paperFileList |%> \out ->
      copyFile' (fromBuild out) out

    -- copy files out of the _build directory
    resultFileList |%> \out ->
      copyFile' (toBuild out) out

    -- clean files by removing the _build directory
    "clean" ~> do
      putNormal "Cleaning files in _build"
      removeFilesAfter "_build" ["//*"]
      putNormal "Cleaning files in auto"
      removeFilesAfter "auto" ["//*"]
