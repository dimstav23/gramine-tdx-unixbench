/*******************************************************************************
 *          
 *  The BYTE UNIX Benchmarks - Release 3
 *          Module: timeit.c   SID: 3.3 5/15/91 19:30:21
 *******************************************************************************
 * Bug reports, patches, comments, suggestions should be sent to:
 *
 *	Ben Smith, Rick Grehan or Tom Yager
 *	ben@bytepb.byte.com   rick_g@bytepb.byte.com   tyager@bytepb.byte.com
 *
 *******************************************************************************
 *  Modification Log:
 *  May 12, 1989 - modified empty loops to avoid nullifying by optimizing
 *                 compilers
 *  August 28, 1990 - changed timing relationship--now returns total number
 *	                  of iterations (ty)
 *  October 22, 1997 - code cleanup to remove ANSI C compiler warnings
 *                     Andy Kahn <kahn@zk3.dec.com>
 *
 ******************************************************************************/

/* this module is #included in other modules--no separate SCCS ID */

/*
 *  Timing routine
 *
 */

#include <signal.h>
#include <unistd.h>

#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

typedef struct {
    int seconds;
    void (*func)();
} thread_data_t;

void* thread_func(void* arg) {
    thread_data_t* data = (thread_data_t*)arg;
    sleep(data->seconds);
    data->func();
    free(data);  // Free the allocated memory for thread data
    return NULL;
}

void wake_me(int seconds, void (*func)()) {
    pthread_t thread;
    thread_data_t* data = malloc(sizeof(thread_data_t));
    if (data == NULL) {
        perror("Failed to allocate memory");
        return;
    }
    data->seconds = seconds;
    data->func = func;

    if (pthread_create(&thread, NULL, thread_func, data) != 0) {
        perror("Failed to create thread");
        free(data);
        return;
    }

    pthread_detach(thread);  // Detach the timer thread
}