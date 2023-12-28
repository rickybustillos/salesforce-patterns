/**
 * @description: Test class for ScheduleJobs
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class ScheduleJobsTest {

    @isTest
    public static void thirtyMinutesScheduledJobsCreation  () {

        ScheduleJobs schedule = new ScheduleJobs();
        ScheduleJobs.jobCountForTest = 100;

        String jobName = '%Test  ' + ScheduleJobs.jobCountForTest + '%';

        Test.startTest();

        schedule.intoMinutesInterval( new JobTest() , 30 );

        List<AggregateResult> scheduledJobs = findCronJob( jobName );

        Test.stopTest();

        Assert.areEqual( 2, (Integer) scheduledJobs.get(0).get('total'), '2 jobs should be created' );
    }


    @isTest
    public static void scheduledJobAbort  () {

        ScheduleJobs schedule = new ScheduleJobs();
        ScheduleJobs.jobCountForTest = 150;

        String jobName = '%Test  ' + ScheduleJobs.jobCountForTest + '%';

        schedule.intoMinutesInterval( new JobTest() , 30 );

        List<AggregateResult> scheduledJobs = findCronJob( jobName );

        Assert.areEqual( 2, (Integer) scheduledJobs.get(0).get('total'), '2 jobs should be created' );

        Test.startTest();

        schedule.abort( jobName );

        Test.stopTest();

        scheduledJobs = findCronJob( jobName );

        Assert.areEqual( 0, (Integer) scheduledJobs.get(0).get('total'), 'No jobs should be found' );
    }

    @isTest
    public static void scheduleJobToExecuteInNextMinute  () {

        ScheduleJobs schedule = new ScheduleJobs ();
        ScheduleJobs.jobCountForTest = 110;

        String jobName = '%Test  '+ ScheduleJobs.jobCountForTest +'%';

        Test.startTest();

        schedule.intoNextMinutes( new JobTest() , 2);

        List<AggregateResult> results = findCronJob(jobName);

        Assert.areEqual(1, (Integer) results.get(0).get('total'), '1 job should be created' );

        Test.stopTest();
    }

    private static List<AggregateResult> findCronJob (String jobName) {
        return [ SELECT count(Id) total FROM CronTrigger WHERE CronJobDetail.Name LIKE :jobName ];
    }

    public class JobTest implements Schedulable {

        Boolean executed = false;

        public void execute (SchedulableContext context) {
            executed = true;
        }

    }

}