package drop.persist
{
	import ash.core.Engine;
	import ash.core.NodeList;

	import drop.board.EntityManager;
	import drop.component.GameStateComponent;
	import drop.component.MatchComponent;
	import drop.component.SpawnerComponent;
	import drop.component.TransformComponent;
	import drop.node.TypeNode;

	import flash.filesystem.File;

	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class Persister
	{
		private static const FILE_NAME : String = "drop.txt";

		private var engine : Engine;
		private var entityManager : EntityManager;

		public function Persister(engine : Engine, entityManager : EntityManager)
		{
			this.engine = engine;
			this.entityManager = entityManager;
		}

		public function hasPersistedData() : Boolean
		{
			return getSaveStream(false) != null;
		}

		public function persist() : void
		{
			var typeNodeList : NodeList = engine.getNodeList(TypeNode);
			var objects : Array = [];
			for (var typeNode : TypeNode = typeNodeList.head; typeNode; typeNode = typeNode.next)
			{
				var object : Object = {};

				object["TypeComponent"] = { "type": typeNode.typeComponent.type };

				var gameStateComponent : GameStateComponent = typeNode.entity.get(GameStateComponent);
				if (gameStateComponent != null)
				{
					var matchPatternPointsObject : Object = {};
					for (var pattern : * in gameStateComponent.matchPatternLevels)
					{
						matchPatternPointsObject[pattern] = gameStateComponent.matchPatternLevels[pattern].points;
					}
					object["GameStateComponent"] = { "uniqueId": gameStateComponent.uniqueId, "credits": gameStateComponent.credits, "pendingCreditsRecord": gameStateComponent.pendingCreditsRecord, "matchPatternPoints": matchPatternPointsObject };
				}

				var spawnerComponent : SpawnerComponent = typeNode.entity.get(SpawnerComponent);
				if (spawnerComponent != null)
				{
					object["SpawnerComponent"] = { "spawnerLevel": spawnerComponent.spawnerLevel };
				}

				var matchComponent : MatchComponent = typeNode.entity.get(MatchComponent);
				if (matchComponent != null)
				{
					object["MatchComponent"] = { "type": matchComponent.type };
				}

				var transformComponent : TransformComponent = typeNode.entity.get(TransformComponent);
				if (transformComponent != null)
				{
					object["TransformComponent"] = { "x": transformComponent.x, "y": transformComponent.y };
				}

				objects.push(object);
			}

			var fileStream : FileStream = getSaveStream(true);
			fileStream.writeUTF(JSON.stringify(objects));
			fileStream.close();
		}

		public function restore() : void
		{
			var fileStream : FileStream = getSaveStream(false);
			var objects : Array = JSON.parse(fileStream.readUTF()) as Array;
			for each (var object : Object in objects)
			{
				switch (object["TypeComponent"]["type"])
				{
					case "game":
						engine.addEntity(entityManager.createGame(object["GameStateComponent"]["uniqueId"], object["GameStateComponent"]["credits"], object["GameStateComponent"]["pendingCreditsRecord"], object["GameStateComponent"]["matchPatternPoints"]));
						break;
					case "tile":
						engine.addEntity(entityManager.createTile(object["TransformComponent"]["x"], object["TransformComponent"]["y"], object["MatchComponent"]["type"]));
						break;
					case "lineBlast":
						engine.addEntity(entityManager.createLineBlast(object["TransformComponent"]["x"], object["TransformComponent"]["y"], object["MatchComponent"]["type"]));
						break;
					case "spawner":
						engine.addEntity(entityManager.createSpawner(object["TransformComponent"]["x"], object["TransformComponent"]["y"], object["SpawnerComponent"]["spawnerLevel"]));
						break;
					case "blocker":
						engine.addEntity(entityManager.createBlocker(object["TransformComponent"]["x"], object["TransformComponent"]["y"]));
						break;
				}
			}
			fileStream.close();
		}

		private function getSaveStream(write : Boolean, sync : Boolean = true) : FileStream
		{
			var file : File = File.applicationStorageDirectory.resolvePath(FILE_NAME);

			if (!file.exists &&
					!write)
			{
				return null;
			}

			var fileStream : FileStream = new FileStream();
			try
			{
				if (write && !sync)
				{
					fileStream.openAsync(file, FileMode.WRITE);
				}
				else
				{
					fileStream.open(file, write ? FileMode.WRITE : FileMode.READ);
				}
			}
			catch (error : Error)
			{
				return null;
			}
			return fileStream;
		}
	}
}
