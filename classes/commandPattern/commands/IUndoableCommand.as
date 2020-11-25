package commandPattern.commands
{
	public interface IUndoableCommand
	{
		function execute():void;
		function undo():void;
	}
}