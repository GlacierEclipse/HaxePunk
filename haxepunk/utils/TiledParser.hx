package haxepunk.utils;

import haxe.xml.Access;
import haxepunk.assets.AssetCache;

/*
* Contains information on a single Tile Layer.
*/
class TiledTileLayer
{
    public var arr2DTileLayer:Array<Array<Int>>;
    public var rows:Int;
    public var columns:Int;

    public function new() 
    {
        arr2DTileLayer = new Array<Array<Int>>();
        rows = -1;
        columns = -1;
    }
}

class TiledObjectGroup
{
    public var arrTiledObjects:Array<TiledObject>;

    public function new() 
    {
        arrTiledObjects = new Array<TiledObject>();
    }
}

class TiledObject
{
    public var x:Float;
    public var y:Float;
    public var w:Int;
    public var h:Int; 
    public var name:String;
    public var properties:Map<String, Float>;

    public function new(x:Float, y:Float, w:Int, h:Int, name:String) 
    {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.name = name;

        properties = new Map<String, Float>();
    }
}

class TiledParser 
{
    // Tile layers are stored here.
    public var map2DTileLayers:Map<String, TiledTileLayer>;

    // Object layers are stored here.
    public var mapObjectLayers:Map<String, TiledObjectGroup>;

    public function new(sourceTmx:String) 
    {
        map2DTileLayers = new Map<String, TiledTileLayer>();
        mapObjectLayers = new Map<String, TiledObjectGroup>();
        
        var rootXml:Xml = Xml.parse(AssetCache.global.getText(sourceTmx));

        var xmlAccess:Access = new Access(rootXml.firstElement());

        // Tile Layers
        for (layer in xmlAccess.nodes.layer)
        {
            var layerName:String = layer.att.name;
            
            var layerWidth:Int = Std.parseInt(layer.att.width);
            var strLevel:String = layer.node.data.innerData;

            // Create the level entry
            
            var tileLayer:TiledTileLayer = new TiledTileLayer();
            var arr2DTileLayer = tileLayer.arr2DTileLayer;
            map2DTileLayers.set(layerName, tileLayer);
            
            var rows:Array<String> = strLevel.split("\n");
            
            var startRow:Int = 0;
            for (row in 0...rows.length)
            {
                if(rows[row].length < layerWidth)
                    continue;

                if(arr2DTileLayer[startRow] == null)
                    arr2DTileLayer[startRow] = new Array<Int>();

                var cols:Array<String> = rows[row].split(",");
                for (col in 0...cols.length)
                {
                    var tileInd:Int = Std.parseInt(cols[col]);
                    if(tileInd == null)
                        continue;
                    
                    arr2DTileLayer[startRow][col] = tileInd;
                }
                if(tileLayer.columns == -1)
                    tileLayer.columns = arr2DTileLayer[startRow].length;

                startRow++;
            }

            tileLayer.rows = arr2DTileLayer.length;
        }


        // Parse Object groups
        for (objectgroup in xmlAccess.nodes.objectgroup)
        {
            var objectGroupName:String = objectgroup.att.name;

            // Create the object entry
            var tiledObjectGroup:TiledObjectGroup = new TiledObjectGroup();
            mapObjectLayers.set(objectGroupName, tiledObjectGroup);

            for (object in objectgroup.nodes.object)
            {
                var x:Float = Std.parseFloat(object.att.x);
                var y:Float = Std.parseFloat(object.att.y);
                var w:Int = Std.parseInt(object.att.width);
                var h:Int = Std.parseInt(object.att.height);
                var name:String = object.att.name;
                
                var tiledObject:TiledObject = new TiledObject(x, y, w, h, name);
                tiledObjectGroup.arrTiledObjects.push(tiledObject);

                for (properties in object.nodes.properties)
                {
                    for (property in properties.nodes.property)
                    {
                        var nameProperty:String = property.att.name;
                        var valueProperty:Float = Std.parseFloat(property.att.value);
                        
                        tiledObject.properties.set(nameProperty, valueProperty);
                    }
                }
            }
        }
    }
}