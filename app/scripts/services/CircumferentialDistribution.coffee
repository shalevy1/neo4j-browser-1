###!
Copyright (c) 2002-2013 "Neo Technology,"
Network Engine for Objects in Lund AB [http://neotechnology.com]

This file is part of Neo4j.

Neo4j is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

'use strict';

angular.module('neo4jApp.services')
  .service 'CircumferentialDistribution', () ->

    @distribute = (arrowAngles, minSeparation) ->
      list = []
      for own key, angle of arrowAngles.floating
        list.push
          key: key
          angle: angle
          floating: true

      for own key, angle of arrowAngles.fixed
        list.push
          key: key
          angle: angle
          floating: false

      list.sort((a, b) -> a.angle - b.angle)

      runsOfTooDenseArrows = []

      length = (startIndex, endIndex) ->
        if startIndex < endIndex
          endIndex - startIndex + 1
        else
          endIndex + list.length - startIndex + 1

      angleBetween = (startIndex, endIndex) ->
        if startIndex < endIndex
          list[endIndex].angle - list[startIndex].angle
        else
          360 - (list[startIndex].angle - list[endIndex].angle)

      tooDense = (startIndex, endIndex) ->
        angleBetween(startIndex, endIndex) < length(startIndex, endIndex) * minSeparation

      wrapIndex = (index) ->
        if index == -1
          list.length - 1
        else if index >= list.length
          index - list.length
        else
          index

      wrapAngle = (angle) ->
        if angle < 0
          angle + 360
        else if angle >= 360
          angle - 360
        else
          angle

      expand = (startIndex, endIndex) ->
        if length(startIndex, endIndex) < list.length
          if list[wrapIndex(endIndex + 1)].floating and tooDense(startIndex, wrapIndex(endIndex + 1))
            return expand startIndex, wrapIndex(endIndex + 1)
          if list[wrapIndex(startIndex - 1)].floating and tooDense(wrapIndex(startIndex - 1), endIndex)
            return expand wrapIndex(startIndex - 1), endIndex

        runsOfTooDenseArrows.push(
          start: startIndex
          end: endIndex
        )

      for i in [0..list.length - 2]
        if list[i].floating and list[i + 1].floating and tooDense(i, i + 1)
          expand i, i + 1

      result = {}

      for own key, angle of arrowAngles.fixed
        result[key] = arrowAngles.fixed[key]

      midwayBetween = (startIndex, endIndex) ->
        list[startIndex].angle + angleBetween(startIndex, endIndex) / 2

      for run in runsOfTooDenseArrows
        center = midwayBetween(run.start, run.end)
        separation = minSeparation
        runLength = length(run.start, run.end)
        if runLength < list.length and tooDense(wrapIndex(run.start - 1), wrapIndex(run.end + 1))
          center = midwayBetween(wrapIndex(run.start - 1), wrapIndex(run.end + 1))
          separation = angleBetween(wrapIndex(run.start - 1), wrapIndex(run.end + 1)) / (runLength + 1)
        else if runLength < list.length and tooDense(wrapIndex(run.start - 1), wrapIndex(run.end))
          center = list[wrapIndex(run.start - 1)].angle + (runLength + 1) / 2 * separation
        else if runLength < list.length and tooDense(wrapIndex(run.start), wrapIndex(run.end + 1))
          center = wrapAngle(list[wrapIndex(run.end + 1)].angle - (runLength + 1) / 2 * separation)

        for i in [0..runLength - 1]
          rawAngle = center + (i - (runLength - 1) / 2) * separation
          result[list[wrapIndex(run.start + i)].key] = wrapAngle(rawAngle)

      for own key, angle of arrowAngles.floating
        if !result.hasOwnProperty(key)
          result[key] = arrowAngles.floating[key]

      result