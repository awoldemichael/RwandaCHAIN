## Data sources
* Rwanda administrative files are from the [National Institute of Statistics Rwanda](http://geodata.nisr.opendata.arcgis.com/datasets?q=Rwanda)
* Rwanda admin3 shapefile simplified using 5% setting [mapshaper](http://www.mapshaper.org/)
* Converted to geoJSON in QGIS


## Querying the database
* activity list: http://devgeocenter.org/rwanda-programs/content/?action=query&target=acts-list
* intervention list: http://devgeocenter.org/rwanda-programs/content/?action=query&target=intvs-list
* partner/intervention/location list: http://devgeocenter.org/rwanda-programs/content/?action=query&target=acts-locs
* $.trim(): jQuery code to remove trailing spaces.


## Setting up local server to test
* Navigate to dir in terminal
* `python -m SimpleHTTPServer 8000`
* navigate to http://localhost:8000/ in web browser

## git committing to Baboyma's repo
* Navigate to folder with git repo

### pull
* `git fetch` to check if need to pull
* `git status`: # of commits behind/ahead
* `git pull`: pull commits

### push
* `git add .`: add all new files
* `git commit -am "<message>"`: commit all changes w/ message
* `git push origin dev:dev`: push
