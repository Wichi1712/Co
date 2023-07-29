local sheetShapes = {}

sheetShapes.sheet =
{
    frames =
    {
        {   -- 1) square0
            x = 0,
            y = 0,
            width = 32,
            height = 32
        },
        {   -- 2) square1
            x = 32,
            y = 0,
            width = 32,
            height = 32
        },
        {   -- 3) triangle0
            x = 64,
            y = 0,
            width = 32,
            height = 32
        },
        {   -- 4) triangle1
            x = 96,
            y = 0,
            width = 32,
            height = 32
        },
        {   -- 5) circle0
            x = 128,
            y = 0,
            width = 32,
            height = 32
        },
        {   -- 6) circle1
            x = 160,
            y = 0,
            width = 32,
            height = 32
        },
    },
}

sheetShapes.frameIndex =
{
    ["square0"] = 1,
    ["square1"] = 2,
    ["triangle0"] = 3,
    ["triangle1"] = 4,
    ["circle0"] = 5,
    ["circle1"] = 6,
}

sheetShapes.sequenceData = {
    {name="shapeSquare", start=1,count=2,time=300},--,loopCount=5},
    {name="shapeTriangle", start=3,count=2,time=1000},
    {name="shapeCircle", start=5,count=2,time=1000}
}

function sheetShapes:getSheet()
    return self.sheet;
end

function sheetShapes:getFrameIndex()
  return self.frameIndex[name];
end

function sheetShapes:getSequenceData()
  return self.sequenceData;
end

return sheetShapes