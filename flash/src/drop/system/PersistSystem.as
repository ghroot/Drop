package drop.system
{
	import ash.core.System;

	import drop.persist.Persister;

	public class PersistSystem extends System
	{
		private var persister : Persister;

		public function PersistSystem(persister : Persister)
		{
			this.persister = persister;
		}

		override public function update(time : Number) : void
		{
			persister.persist();
		}
	}
}
