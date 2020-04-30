# About

Data from this week's TidyTuesday came from [BBC Music's poll](http://www.bbc.com/culture/story/20191007-the-greatest-hip-hop-songs-of-all-time) where they asked 100 critics across the world to name their favorite hip-hop songs.

# My questions:
1. Is there a specific era that is over-represented in critics' favorite tracks?  
2. Which tracks were mentioned the most in critics' Top 5?  
3. How do the features of tracks (e.g. 'speechiness' and 'instrumentalness') change across time?  

# Results
There's a big preference for throwbacks:  

<img src="https://github.com/rrobinn/tidy-tuesday/blob/master/20200414-Rap-Artists/figs/unnamed-chunk-3-1.png" height="50%" width="50%">  

People are really into [The Notorious B.I.G.](http://www.bbc.com/culture/story/20191007-why-juicy-is-the-greatest-hip-hop-song-of-all-time)  
<img src="https://github.com/rrobinn/tidy-tuesday/blob/master/20200414-Rap-Artists/figs/unnamed-chunk-5-1.png" height="50%" width="50%">  

I used the <b>Spotify Web API</b> to analyze the actual contents of the tracks that people were really into.  

Here, you can see the <b>speechiness</b> of the top-selected tracks, broken down by era:  
<img src="https://github.com/rrobinn/tidy-tuesday/blob/master/20200414-Rap-Artists/figs/unnamed-chunk-7-1.png" height="50%" width="50%">  

And here's their <b>instrumentalness</b>:  
<img src="https://github.com/rrobinn/tidy-tuesday/blob/master/20200414-Rap-Artists/figs/unnamed-chunk-7-2.png" height="50%" width="50%">  

Interesting that Eminem's 'Lose Yourself' ranks high on speechiness AND instrumentalness. When I listened to the track this makes sense - Eminem raps really fast, but there's a long instrumental intro. 
