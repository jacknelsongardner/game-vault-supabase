// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  try {
    // Query to get all games with their related data
    const { data: games, error: gamesError } = await supabase
      .from('game')
      .select(`
        id,
        name,
        data
      `)

    if (gamesError) {
      throw gamesError
    }

    // Process each game to extract and format the required information
    const formattedGames = await Promise.all(
      games.map(async (game) => {
        const gameData = game.data || {}
        
        // Get cover art
        let coverUrl = null
        if (gameData.cover) {
          const { data: coverData } = await supabase
            .from('cover')
            .select('url')
            .eq('id', gameData.cover)
            .single()
          
          coverUrl = coverData?.url || null
        }

        // Get genres (get the first/primary genre)
        let primaryGenre = null
        if (gameData.genres && gameData.genres.length > 0) {
          const { data: genreData } = await supabase
            .from('genre')
            .select('name')
            .eq('id', gameData.genres[0])
            .single()
          
          primaryGenre = genreData?.name || null
        }

        // Get platforms this game was released on
        const { data: platformsData } = await supabase
          .from('played_on')
          .select(`
            platform:platform_id (
              id,
              name
            )
          `)
          .eq('game_id', game.id)

        const platforms = platformsData?.map(p => ({
          id: p.platform?.id,
          name: p.platform?.name
        })).filter(p => p.id && p.name) || []

        // Get review average
        const { data: reviewsData } = await supabase
          .from('reviews')
          .select('star_rating')
          .eq('game_id', game.id)
          .not('star_rating', 'is', null)

        let reviewAverage = null
        if (reviewsData && reviewsData.length > 0) {
          const total = reviewsData.reduce((sum, review) => sum + review.star_rating, 0)
          reviewAverage = total / reviewsData.length
        }

        // Extract earliest release date from JSONB data
        let earliestReleaseDate = null
        if (gameData.first_release_date) {
          // IGDB stores dates as Unix timestamps
          earliestReleaseDate = new Date(gameData.first_release_date * 1000).toISOString()
        } else if (gameData.release_dates && gameData.release_dates.length > 0) {
          // If we have individual release dates, find the earliest
          const dates = gameData.release_dates
            .filter(rd => rd.date)
            .map(rd => new Date(rd.date * 1000))
            .sort((a, b) => a.getTime() - b.getTime())
          
          if (dates.length > 0) {
            earliestReleaseDate = dates[0].toISOString()
          }
        }

        return {
          id: game.id,
          title: game.name,
          coverArt: coverUrl,
          primaryGenre: primaryGenre,
          earliestReleaseDate: earliestReleaseDate,
          reviewAverage: reviewAverage,
          platforms: platforms
        }
      })
    )

    return new Response(
      JSON.stringify({
        success: true,
        data: formattedGames,
        total: formattedGames.length
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (err) {
    console.error('Error fetching games:', err)
    
    return new Response(
      JSON.stringify({
        success: false,
        error: err.message,
        message: 'Failed to fetch games'
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

/* To invoke locally:

  1. Run `supabase start`
  2. Make an HTTP request:

  curl -i --location --request GET 'http://127.0.0.1:54321/functions/v1/get-all-games' \
    --header 'Authorization: Bearer [YOUR_SUPABASE_ANON_KEY]'

*/