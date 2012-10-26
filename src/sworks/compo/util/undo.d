module sworks.compo.util.undo;

import std.container;

//////////////////////////////////////////////////////////////////////
//
class UndoObject
{
	void delegate() undoFunc;
	void delegate() redoFunc;
	this( void delegate() undoFunc, void delegate() redoFunc )
	{
		this.undoFunc = undoFunc; this.redoFunc = redoFunc;
	}
}

//////////////////////////////////////////////////////////////////////
//
class UndoManager
{
	SList!UndoObject undoBuffer;
	SList!UndoObject redoBuffer;

	@property bool canUndo() { return !undoBuffer.empty; }
	@property bool canRedo() { return !redoBuffer.empty; }

	void clear() { undoBuffer.clear(); redoBuffer.clear(); }

	void Do( UndoObject o )
	{
		redoBuffer.clear();
		undoBuffer.insertFront( o );
	}

	void Undo()
	{
		if( undoBuffer.empty ) return;
		undoBuffer.front.undoFunc();
		redoBuffer.insertFront( undoBuffer.front );
		undoBuffer.removeFront;
	}

	void Redo()
	{
		if( redoBuffer.empty ) return;
		redoBuffer.front.redoFunc();
		undoBuffer.insertFront( redoBuffer.front );
		redoBuffer.removeFront;
	}
}
