package org.molgenis.compute.test.executor;

/**
 * Created with IntelliJ IDEA. User: georgebyelas Date: 22/08/2012 Time: 14:21
 * To change this template use File | Settings | File Templates.
 */
public interface ComputeExecutor
{
	void executeTasks(String backend);

	void startHost(String name);

	void startHostWithCredentials(String host, String user, String password, int port);
}
