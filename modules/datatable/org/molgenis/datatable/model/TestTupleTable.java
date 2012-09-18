package org.molgenis.datatable.model;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.molgenis.model.elements.Field;
import org.molgenis.util.SimpleTuple;
import org.molgenis.util.Tuple;

public class TestTupleTable extends AbstractTupleTable
{
	private int rowCount;
	private List<Field> columns;

	public TestTupleTable()
	{
		this(1000000, 1000000);
	}

	public TestTupleTable(int colCount, int rowCount)
	{
		this.rowCount = rowCount;

		columns = new ArrayList<Field>(colCount);
		for (int i = 1; i <= colCount; i++)
		{
			columns.add(new Field("Field" + i));
		}
	}

	@Override
	public List<Field> getAllColumns() throws TableException
	{
		return columns;
	}

	@Override
	public Iterator<Tuple> iterator()
	{
		try
		{
			return new TupleTableIterator(this);
		}
		catch (TableException e)
		{
			throw new RuntimeException(e);
		}
	}

	@Override
	public int getCount() throws TableException
	{
		return rowCount;
	}

	@Override
	protected Tuple getValues(int row, int colStart, int colEnd) throws TableException
	{
		Tuple tuple = new SimpleTuple();

		for (int col = colStart; col < colEnd; col++)
		{
			tuple.set(columns.get(col).getName(), (row + 1) + "-" + (col + 1));
		}

		return tuple;
	}

}
