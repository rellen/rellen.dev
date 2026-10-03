-- List of talks using the Talk schema
let Talk = ./Talk.dhall

in  [ Talk::{
      , title = "GraphQL APIs for Postgres with pg_graphql"
      , description =
          ''
          A lightweight extension to Postgres that adds a GraphQL layer over
          your databases, in the same style as PostgREST.
          ''
      , organisation = "GraphQL Australia"
      , year = 2022
      , month = 5
      , video = Some "https://youtu.be/zBdS12xvsSI"
      }
    , Talk::{
      , title = "Macro Madness: when busting boilerplate backfires"
      , description =
          ''
          A brief talk about an adventure in writing some macro code to reduce
          boiler-plate.
          ''
      , organisation = "Elixir Australia"
      , year = 2022
      , month = 2
      , video = Some "https://youtu.be/Y-1xhtVz-B4"
      }
    , Talk::{
      , title = "Getting up and running with PromEx"
      , description =
          ''
          Walk through setting up a local PromEx environment including
          Prometheus and Grafana with Docker to show how quickly you can get
          metrics in your Elixir applications.
          ''
      , organisation = "Elixir Australia"
      , year = 2021
      , month = 9
      , video = Some "https://youtu.be/bLdheYG7BwQ"
      }
    , Talk::{
      , title = "OTP24 and Elixir 1.12 Release Bonanza!"
      , description =
          ''
          Covers the release of OTP24 and Elixir 1.12.
          ''
      , organisation = "Elixir Australia"
      , year = 2021
      , month = 5
      , video = Some "https://youtu.be/ucgYT3YUVS8"
      }
    , Talk::{
      , title = "Kicking the tires on Nx - Numerical Elixir"
      , description =
          ''
          One of the most hotly anticipated libraries to be added to the
          Elixir ecosystem.
          ''
      , organisation = "Elixir Australia"
      , year = 2021
      , month = 3
      , video = Some "https://youtu.be/SgSbaGm5nR0"
      }
    , Talk::{
      , title = "gRPC in Elixir"
      , description =
          ''
          Whirlwind tour of gRPC in Elixir.
          ''
      , organisation = "Elixir Australia"
      , year = 2020
      , month = 11
      , video = Some "https://youtu.be/1jwruFHxPJ4"
      }
    , Talk::{
      , title = "A Quick Introduction to Erlang and the OTP Libraries"
      , description = ""
      , organisation = "BFPG"
      , year = 2013
      , month = 10
      , video = Some "https://vimeo.com/78207134"
      }
    ]
